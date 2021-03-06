//
//  Modal form for crearing and editing a diary record
//

import Foundation
import UIKit

class EditRecordViewController: UIViewController {
    
    fileprivate let outerMargin: CGFloat = 12.0
    fileprivate let subviewsVerticalSpacing: CGFloat = 6.0
    fileprivate let datePickerHeight: CGFloat = 200.0
    fileprivate var viewModel: EditRecordViewModel
    
    fileprivate lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.height(to: self.datePickerHeight)
        return datePicker
    }()
    
    fileprivate lazy var sugarLevelTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.placeholder = "Sugar level ❤️"
        return textField
    }()
    
    fileprivate lazy var medicationAmountTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.placeholder = "Medication amount 💉"
        
        return textField
    }()
    
    fileprivate lazy var breadUnitsTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.placeholder = "Bread units 🍞"
        
        return textField
    }()
    
    fileprivate lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.datePicker,
                                                       self.sugarLevelTextField,
                                                       self.medicationAmountTextField,
                                                       self.breadUnitsTextField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = self.subviewsVerticalSpacing
        
        return stackView
    }()
    
    // MARK: Lifecycle
    
    init(_ viewModel: EditRecordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupData()
        setupNavbar()
        setupStackView()
        sugarLevelTextField.becomeFirstResponder()
    }
    
    // MARK: - Views Setup
    
    func setupData() {
        datePicker.date = viewModel.recordDate()
        sugarLevelTextField.text = viewModel.recordSugarLevelString()
        medicationAmountTextField.text = viewModel.recordMedicationAmountString()
    }
    
    func setupNavbar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(pop))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(save))
    }
    
    func setupStackView() {
        view.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: outerMargin).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -outerMargin).isActive = true
        stackView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
    }
    
    // MARK: Form actions
    
    func save() {
        let (isValid, errorText) = viewModel.validateForm()
        if isValid {
            viewModel.saveChanges()
            view.endEditing(true)
            navigationController?.dismiss(animated: true, completion: viewModel.updateList)
        } else {
            presentErrorAlert(with: errorText)
        }
    }
    
    func presentErrorAlert(with text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    func pop() {
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func datePickerValueChanged() {
        viewModel.setDate(date: datePicker.date)
    }
    
}

extension EditRecordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textBeforeUpdate = (textField.text as NSString?) ?? ""
        let textAfterUpdate = textBeforeUpdate.replacingCharacters(in: range, with: string)
        
        if textField === sugarLevelTextField {
            viewModel.setSugarLevel(levelString: textAfterUpdate)
        }
        else if textField === medicationAmountTextField {
            viewModel.setMedicationAmount(amountString: textAfterUpdate)
        }
        else if textField === breadUnitsTextField {
            viewModel.setBreadUnits(unitsString: textAfterUpdate)
        }
        
        return true
    }
}
