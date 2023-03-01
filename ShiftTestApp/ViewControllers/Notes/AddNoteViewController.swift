//
//  AddNoteViewController.swift
//  ShiftTestApp
//
//  Created by Илья Дубенский on 24.02.2023.
//

import UIKit

class AddNoteViewController: UIViewController {

    // MARK: - Private Properties
    var note: Note?

    // MARK: -  UI Elements
    private lazy var noteTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.text = "TITLE"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()

    private lazy var noteTitleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .white
        textField.placeholder = "Input Note Name..."
        textField.layer.cornerRadius = 12
        textField.font = .systemFont(ofSize: 15)
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.height))
        setKeyboardSettings(forUITextField: textField)
        return textField
    }()

    private var noteTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.text = "TEXT"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()

    private var noteTextTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .white

        textView.text = "Some Note Text..."

        textView.font = .systemFont(ofSize: 15)
        textView.layer.cornerRadius = 12

        textView.textColor = UIColor.systemGray3

        textView.isSelectable = true
        textView.isEditable = true
        return textView
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

// MARK: - Setup MainView and NavBar
extension AddNoteViewController {
    private func setupView() {
        view.backgroundColor = .systemGray6
        self.noteTitleTextField.delegate = self
        self.noteTextTextView.delegate = self
        setupNavigationBar()
        addSubviews()
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        noteTitleTextField.becomeFirstResponder()
        noteTextTextView.becomeFirstResponder()
        if let note {
            noteTitleTextField.text = note.title
            noteTextTextView.text = note.text
            noteTextTextView.textColor = .black
        }
    }

    private func addSubviews() {
        view.addSubview(noteTitleLabel)
        view.addSubview(noteTitleTextField)
        view.addSubview(noteTextLabel)
        view.addSubview(noteTextTextView)
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

        title = note == nil ? "Add Note" : "Note Detail"
        navigationItem.backButtonTitle = "Cancel"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: note == nil ? "Save Note" : "Edit Note",
            style: .plain,
            target: self,
            action: #selector(saveNoteBarButtonDidTapped)
        )
    }

    /// Save Note In CoreData
    @objc private func saveNoteBarButtonDidTapped() {
        print("Save Note Bar Button Did Tapped")
        guard let title = noteTitleTextField.text else { return }
        guard var text = noteTextTextView.text else { return }
        if text == "Some Note Text..." {
            text = ""
        }
        if let note = note {
            if title != "" {
                StorageManager.shared.update(note: note, withNewTitle: title, andText: text)
                navigationController?.popToRootViewController(animated: true)
            } else {
                shakeTextField()
            }
        } else {
            if title != "" {
                StorageManager.shared.saveNote(withTitle: title, andText: text)
                navigationController?.popToRootViewController(animated: true)
            } else {
                shakeTextField()
            }
        }
    }

    private func shakeTextField() {
        noteTitleTextField.placeholder = "Input Title!"
        noteTitleTextField.layer.borderWidth = 1
        noteTitleTextField.layer.borderColor = UIColor.systemRed.cgColor
        noteTitleTextField.shake()
    }
}

// MARK: - Setup Constraints
extension AddNoteViewController {
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            noteTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            noteTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),

            noteTitleTextField.topAnchor.constraint(equalTo: noteTitleLabel.bottomAnchor, constant: 8),
            noteTitleTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            noteTitleTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            noteTitleTextField.heightAnchor.constraint(equalToConstant: 40),

            noteTextLabel.topAnchor.constraint(equalTo:noteTitleTextField.bottomAnchor, constant: 16),
            noteTextLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),

            noteTextTextView.topAnchor.constraint(equalTo: noteTextLabel.bottomAnchor, constant: 8),
            noteTextTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            noteTextTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            noteTextTextView.heightAnchor.constraint(equalToConstant: 140)
        ])
    }
}

// MARK: - Text View Delegate
extension AddNoteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.systemGray3 {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Some Note Text..."
            textView.textColor = UIColor.systemGray3
        }
    }
}

// MARK: - Text Field Delegate + Hide Keyboard
extension AddNoteViewController: UITextFieldDelegate {
    private func setKeyboardSettings(forUITextField textField: UITextField) {
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.clearButtonMode = .always
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
