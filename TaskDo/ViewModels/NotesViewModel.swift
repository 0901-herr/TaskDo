//
//  NotesViewModel.swift
//  TaskDo
//
//  Created by Philippe Yong on 01/02/2021.
//

import Foundation
import Combine

final class NotesViewModel: ObservableObject {
    @Published var taskId = ""
    @Published var newNotesIsTapped = false
    @Published var notes = "Your thoughts..."
    @Published var date = Date()
    @Published var todayNotesExist = false
    
    @Published private(set) var notesList: [NotesItemViewModel] = []
    @Published private(set) var notesItemList: [NotesItem] = []

    private let userService: UserServiceProtocol
    private let notesService: NotesServiceProtocol
    
    private var cancellables: [AnyCancellable] = []
    @Published var error: TaskDoError?
    @Published var taskNotes: [Notes] = []

    init(
        notesService: NotesServiceProtocol = NotesService(),
        userService: UserServiceProtocol = UserService()
    ) {
        self.userService = userService
        self.notesService = notesService
        observeNotes { completion in
            self.notesItemList = self.notesItemList.sorted { $0.date > $1.date }.reversed()
        }
    }
    
    enum Action {
        case addNewNotes
        case saveNotes
    }
    
    func send(action: Action) {
        switch action {
        case .addNewNotes:
            newNotesIsTapped.toggle()
        case .saveNotes:
            if !notes.isEmpty {
                saveNotes()
            }
        }
    }
    
    func saveNotes() {
        currentUserId().flatMap { (userId) -> AnyPublisher<Void, TaskDoError> in
            return self.createNotes(userId: userId)
        }
        .sink { completion in
            switch completion {
            case let .failure(error):
                self.error = error
            case .finished:
                print("finished")
                break
            }
        } receiveValue: { _ in
            print("success")
        }
        .store(in: &cancellables)
    }
    
    private func observeNotes(completion: @escaping (Bool) -> Void) {
        userService.currentUserPublisher()
            .compactMap { $0?.uid }
            .flatMap { [weak self] userId -> AnyPublisher<[Notes], TaskDoError> in
                guard let self = self else { return Fail(error: .default()).eraseToAnyPublisher() }
                return self.notesService.observeChallenges(userId: userId)
            }
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case let .failure(error):
                    self.error = error
                case .finished:
                    print("finished")
                }
            } receiveValue: { [weak self] notes in
                guard let self = self else { return }
                self.error = nil
                self.notesList = notes.map { note in
                    .init(note)
                }
                completion(true)
            }.store(in: &cancellables)
    }

    private func currentUserId() -> AnyPublisher<UserId, TaskDoError> {
        print("getting user id")
        return userService.currentUserPublisher().flatMap { user -> AnyPublisher<UserId, TaskDoError> in
            if let userId = user?.uid {
                print("user is logged in...")
                return Just(userId)
                    .setFailureType(to: TaskDoError.self)
                    .eraseToAnyPublisher()
            }
            else {
                print("user is being logged in anonymously...")
                return self.userService
                    .signInAnonymously()
                    .map { $0.uid }
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    private func createNotes(userId: UserId) -> AnyPublisher<Void, TaskDoError> {
        var notesItemList: [NotesItem] = []
        
        for item in notesList {
            if taskId == item.id {
                notesItemList = item.notesItem
            }
        }
        
        if newNotesIsTapped {
            notesItemList.append(NotesItem(date: Date(), text: self.notes))
            newNotesIsTapped = false
        }
        else {
            for index in 0..<notesItemList.count {
                if getFormattedDate(notesItemList[index].date) == getFormattedDate(self.date) {
                    notesItemList[index] = NotesItem(date: notesItemList[index].date, text: self.notes)
                    print("ADDED HERE 1: \(notesItemList[index])") // update notes
                    break
                }
            }
        }
        
        print("notes item list: \(notesItemList)")
        print("NOTES SAVED: \(notesItemList)")
        
        let notes = Notes(
            id: taskId,
            notes: notesItemList,
            userId: userId
        )
        
        return notesService.create(notes).eraseToAnyPublisher()
    }
}

extension NotesViewModel {
    func getFormattedDate(_ date: Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "E dd.MM"
        return format.string(from: date)
    }
}

struct NotesItemViewModel: Identifiable {
    private let notes: Notes
    
    var notesItem: [NotesItem] {
        notes.notes
    }
   
    var id: String {
        notes.id!
    }
    
//    private let onDelete: (String) -> Void
//    private let onToggleComplete: (String, [Activity]) -> Void
    
    init(_ notes: Notes//,
//         onDelete: @escaping (String) -> Void,
//         onToggleComplete: @escaping (String, [Activity]) -> Void
    ) {
        self.notes = notes
//        self.onDelete = onDelete
//        self.onToggleComplete = onToggleComplete
    }
        
//    func send(action: Action) {
//        guard let id = notes.id else { return }
//        switch action {
//        case .delete:
//            onDelete(id)
//        }
//    }
}

extension NotesItemViewModel {
    enum Action {
        case delete
//        case toggleComplete
    }
}


