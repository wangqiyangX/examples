//
//  SupabaseSampleView.swift
//  examples
//
//  Created by wangqiyang on 2025/8/12.
//

import PostgREST
import Supabase
import SwiftUI

nonisolated struct Todo: Codable {
    var id: UUID
    var order: Int
    var content: String
    var isComplete: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        order: Int,
        content: String,
        isComplete: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.order = order
        self.content = content
        self.isComplete = isComplete
        self.createdAt = createdAt
    }
}

@Observable
final class SupabaseSampleViewModel {
    var todoList: [Todo] = []
    var errorDescription: String? = nil
    var fetching: Bool = false
    var inserting: Bool = false

    @ObservationIgnored let client = SupabaseClient(
        supabaseURL: URL(string: "https://bkfvxebdnxxqdawyufwg.supabase.co")!,
        supabaseKey:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJrZnZ4ZWJkbnh4cWRhd3l1ZndnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5ODI1NTksImV4cCI6MjA3MDU1ODU1OX0.NTE2n0a-jBVg0Z9K9IjRNvoVy82PkO36sWPhAt-LazU"
    )

    init() {
        Task {
            await fetchTodos()
        }
    }

    // fetch data
    func fetchTodos() async {
        fetching = true
        do {
            let todos: [Todo] =
                try await client
                .from("todos")
                .select()
                .order("order", ascending: false)
                .execute()
                .value

            self.todoList = todos
        } catch {
            errorDescription = error.localizedDescription
        }
        fetching = false
    }

    func insertTodo(todo: Todo) async {
        inserting = true
        do {
            try await client
                .from("todos")
                .insert(todo)
                .execute()
        } catch {
            errorDescription = error.localizedDescription
        }
        inserting = false
    }

    func upsertTodo(todo: Todo) async {
        do {
            try await client
                .from("todos")
                .upsert(todo)
                .execute()
        } catch {
            errorDescription = error.localizedDescription
        }
    }

    func deleteTodo(todo: Todo) async {
        do {
            try await client
                .from("todos")
                .delete()
                .eq("id", value: todo.id)
                .execute()
        } catch {
            errorDescription = error.localizedDescription
        }
    }
}

struct SupabaseSampleView: View {
    @State private var viewModel = SupabaseSampleViewModel()
    @State private var showInsertTodo = false

    var body: some View {
        List {
            Section {
                if viewModel.fetching {
                    ProgressView()
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach($viewModel.todoList, id: \.id) { $todo in
                        HStack(alignment: .top) {
                            Image(
                                systemName: todo.isComplete
                                    ? "circle.circle.fill" : "circle"
                            )
                            .onTapGesture {
                                todo.isComplete.toggle()
                                Task {
                                    await viewModel.upsertTodo(todo: todo)
                                }
                            }
                            VStack {
                                Text(todo.content)
                            }
                        }
                        .opacity(todo.isComplete ? 0.65 : 1)
                        .swipeActions {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.deleteTodo(todo: todo)
                                }
                            }
                        }
                    }
                }
            } header: {
                Text("Todos")
            } footer: {
                if let fetchError = viewModel.errorDescription {
                    Text(fetchError)
                }
            }
        }
        .toolbar {
            Button {
                showInsertTodo.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showInsertTodo) {
            AddTodoView()
                .environment(viewModel)
        }
    }
}

struct AddTodoView: View {
    @State private var content: String = ""

    @Environment(\.dismiss) private var dismiss
    @Environment(SupabaseSampleViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            Form {
                TextField("Content", text: $content)
            }
            .navigationTitle("Add Todo")
            .toolbar {
                ToolbarItem {
                    if viewModel.inserting {
                        ProgressView()
                    } else {
                        Button(role: .confirm) {
                            Task {
                                let newTodo = Todo(
                                    order: viewModel.todoList.count + 1,
                                    content: content
                                )
                                await viewModel.insertTodo(todo: newTodo)
                                await viewModel.fetchTodos()
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SupabaseSampleView()
    }
}
