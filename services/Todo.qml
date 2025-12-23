pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs

Singleton {
    id: root

    component TodoItem: QtObject {
        required property string id
        required property string text
        required property string description
        required property string status
        required property int priority
        required property list<string> tags
        required property var createdAt
        required property var completedAt
    }

    property Component todoItemComponent: Component {
        TodoItem {}
    }

    property list<TodoItem> todos: []
    property list<TodoItem> started: []
    property list<TodoItem> completed: []

    signal todoAdded(todo: TodoItem)
    signal todoUpdated(todo: TodoItem)
    signal todoDeleted(id: string)
    signal todoMoved(todo: TodoItem, newStatus: string)
    signal saved

    readonly property string username: {
        const user = Quickshell.env("USER");
        return user || "user";
    }

    readonly property string todoFilePath: `/home/${root.username}/.cache/todo.json`
    readonly property var qtResolvedFilePath: Qt.resolvedUrl(root.todoFilePath)

    function printMsg(message, type) {
        if (!GlobalStates.debug && type !== "error") return;
        const msg = "[TODO]: " + message;
        if (type === "error") console.error(msg);
        else if (type === "warn") console.warn(msg);
        else console.log(msg);
    }

    function generateUUID(): string {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, c => {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    function addTodo(text, description, priority, tags) {
        if (!text?.trim()) {
            printMsg("Cannot add todo with empty text", "error");
            return null;
        }
        const todo = todoItemComponent.createObject(root, {
            id: generateUUID(),
            text: text,
            description: description || "",
            status: "todo",
            priority: priority || 2,
            tags: tags || [],
            createdAt: new Date(),
            completedAt: null
        });
        root.todos.push(todo);
        todoAdded(todo);
        printMsg(`Added todo: ${text}`, "info");
        return todo;
    }

    function editTodo(id, updates) {
        const todo = fetchTodoById(id);
        if (!todo) {
            printMsg(`Todo with id ${id} not found`, "error");
            return false;
        }
        if (updates.text !== undefined) todo.text = updates.text;
        if (updates.description !== undefined) todo.description = updates.description;
        if (updates.priority !== undefined) todo.priority = updates.priority;
        if (updates.tags !== undefined) todo.tags = updates.tags;
        todoUpdated(todo);
        printMsg(`Updated todo: ${todo.text}`, "info");
        return true;
    }

    function deleteTodo(id) {
        for (const list of [root.todos, root.started, root.completed]) {
            const index = list.findIndex(t => t.id === id);
            if (index !== -1) {
                const removed = list.splice(index, 1)[0];
                removed.destroy();
                todoDeleted(id);
                printMsg(`Deleted todo: ${removed.text}`, "info");
                return true;
            }
        }
        printMsg(`Todo with id ${id} not found`, "error");
        return false;
    }

    function moveTodo(id, targetStatus) {
        if (!["todo", "started", "completed"].includes(targetStatus)) {
            printMsg(`Invalid target status: ${targetStatus}`, "error");
            return false;
        }
        const todo = fetchTodoById(id);
        if (!todo || todo.status === targetStatus) return false;

        const getList = (status) => status === "todo" ? root.todos : root[status];
        const currentList = getList(todo.status);
        const index = currentList.findIndex(t => t.id === id);
        if (index !== -1) currentList.splice(index, 1);

        const oldStatus = todo.status;
        todo.status = targetStatus;
        todo.completedAt = targetStatus === "completed" ? new Date() : null;

        getList(targetStatus).push(todo);
        todoMoved(todo, targetStatus);
        printMsg(`Moved "${todo.text}" from ${oldStatus} to ${targetStatus}`, "info");
        return true;
    }

    function fetchTodoById(id): TodoItem {
        const lists = [root.todos, root.started, root.completed];
        for (const list of lists) {
            const todo = list.find(t => t.id === id);
            if (todo)
                return todo;
        }
        return null;
    }

    function save() {
        try {
            const data = {
                todos: root.todos.map(todoToJSON),
                started: root.started.map(todoToJSON),
                completed: root.completed.map(todoToJSON)
            };
            todoFileView.setText(JSON.stringify(data, null, 2));
            printMsg(`Saved ${root.todos.length} todos, ${root.started.length} started, ${root.completed.length} completed`, "info");
            saved();
            return true;
        } catch (error) {
            printMsg(`Save failed: ${error}`, "error");
            return false;
        }
    }

    function todoToJSON(todo) {
        return {
            id: todo.id,
            text: todo.text,
            description: todo.description,
            status: todo.status,
            priority: todo.priority,
            tags: todo.tags,
            createdAt: todo.createdAt?.getTime() || null,
            completedAt: todo.completedAt?.getTime() || null
        };
    }

    function jsonToTodo(json) {
        return todoItemComponent.createObject(root, {
            id: json.id,
            text: json.text,
            description: json.description || "",
            status: json.status,
            priority: json.priority || 2,
            tags: json.tags || [],
            createdAt: json.createdAt ? new Date(json.createdAt) : new Date(),
            completedAt: json.completedAt ? new Date(json.completedAt) : null
        });
    }

    function initializeEmptyStructure() {
        root.todos = [];
        root.started = [];
        root.completed = [];
        printMsg("Initialized empty structure", "info");
    }

    function loadFromAdapter(data) {
        try {
            root.todos = (data.todos || []).map(jsonToTodo);
            root.started = (data.started || []).map(jsonToTodo);
            root.completed = (data.completed || []).map(jsonToTodo);
            printMsg(`Loaded ${root.todos.length} todos, ${root.started.length} started, ${root.completed.length} completed`, "info");
        } catch (error) {
            printMsg(`Load failed: ${error}`, "error");
            initializeEmptyStructure();
        }
    }

    function deleteCompleted() {
        const count = root.completed.length;
        root.completed.forEach(t => t.destroy());
        root.completed = [];
        printMsg(`Deleted ${count} completed todos`, "info");
    }

    function getTodosWithTag(tag) {
        return root.todos.filter(t => t.tags.includes(tag));
    }

    function getTodosByPriority() {
        return root.todos.slice().sort((a, b) => b.priority - a.priority);
    }

    Process {
        id: createLogFile
        running: false
        command: ["touch", root.todoFilePath]
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) todoFileView.reload();
            else printMsg(`File creation failed with exit code ${exitCode}`, "error");
        }
    }

    FileView {
        id: todoFileView
        path: root.qtResolvedFilePath
        preload: true
        atomicWrites: true
        printErrors: true
        watchChanges: true

        onLoaded: {
            printMsg("File loaded", "info");
            try {
                const contents = todoFileView.text();
                if (!contents?.trim()) {
                    initializeEmptyStructure();
                    save();
                    return;
                }
                const data = JSON.parse(contents);
                if (data && Array.isArray(data.todos) && Array.isArray(data.started) && Array.isArray(data.completed)) {
                    loadFromAdapter(data);
                } else {
                    initializeEmptyStructure();
                    save();
                }
            } catch (error) {
                printMsg(`Parse error: ${error}`, "error");
                initializeEmptyStructure();
                save();
            }
        }

        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                printMsg("File not found, creating", "warn");
                createLogFile.running = true;
            } else {
                printMsg("Failed to load file", "error");
            }
        }
        onFileChanged: reload()
    }

    Component.onCompleted: printMsg("Service initialized", "info")
}
