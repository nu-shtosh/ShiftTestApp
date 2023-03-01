//
//  NotesViewController.swift
//  ShiftTestApp
//
//  Created by Илья Дубенский on 24.02.2023.
//

import UIKit
import CoreData

final class NotesViewController: UIViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Private Properties
    private var fetchedResultsController = StorageManager.shared.getFetchedResultsController(
        entityName: "Note",
        keyForSort: "date"
    )

    // MARK: - UI Elements
    private lazy var notesTableView: UITableView = {
        let tableView = UITableView(frame: CGRectZero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGray6
        return tableView
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchNotes()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeTestData()
    }

    // MARK: - Private Methods
    private func fetchNotes() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }

    private func makeTestData() {
        let firstNote: Note? = self.fetchedResultsController.fetchedObjects?.first as? Note
        if firstNote == nil {
            StorageManager.shared.saveNote(withTitle: "Some note", andText: "Some Text")
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notesTableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            notesTableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            notesTableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            notesTableView.reloadRows(at: [indexPath], with: .automatic)
        default: break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notesTableView.endUpdates()
    }
}

// MARK: - Setup MainView and NavBar
extension NotesViewController {
    private func setupView() {
        view.backgroundColor = .systemGray6
        view.addSubview(notesTableView)
        fetchedResultsController.delegate = self
        notesTableView.delegate = self
        notesTableView.dataSource = self
        setupNavigationBar()
        setupConstraints()
    }

    private func setupNavigationBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = .white
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemBlue

        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

        title = "Notes"
        navigationItem.backButtonTitle = "Cancel"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add Note",
            style: .plain,
            target: self,
            action: #selector(addNoteBarButtonDidTapped)
        )
    }

    /// Go To Add Note
    @objc private func addNoteBarButtonDidTapped() {
        print("Add Note Bar Button Did Tapped")
        let addNoteVC = AddNoteViewController()
        addNoteVC.hidesBottomBarWhenPushed = true
        navigationController?.show(addNoteVC, sender: .none)
    }
}

// MARK: - Setup Constraints
extension NotesViewController {
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            notesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            notesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            notesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            notesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - Table View Delegate and Data Source
extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return "NOTES"
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        print("Cell Did Tapped")
        tableView.deselectRow(at: indexPath, animated: true)
        let note = fetchedResultsController.object(at: indexPath) as? Note // 3
        let addNoteVC = AddNoteViewController()
        addNoteVC.note = note
        addNoteVC.hidesBottomBarWhenPushed = true
        navigationController?.show(addNoteVC, sender: .none)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            if let note = self.fetchedResultsController.object(at: indexPath) as? Note {
                StorageManager.shared.delete(note: note)
            }
        }

        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .gray
        let note = fetchedResultsController.object(at: indexPath) as? Note
        cell.contentConfiguration = setContentForCell(with: note)
        return cell
    }

    private func setContentForCell(with note: Note?) -> UIListContentConfiguration {
        var content = UIListContentConfiguration.cell()

        content.textProperties.font = .systemFont(ofSize: 16)

        content.textProperties.color = .black
        content.text = note?.title

        return content
    }
}
