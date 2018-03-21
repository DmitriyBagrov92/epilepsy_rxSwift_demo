//
//  EPError.swift
//  Epilepsy
//
//  Created by DmitriyBagrov on 19/11/2017.
//  Copyright © 2017 DmitriyBagrov. All rights reserved.
//

import Foundation

enum EPError: Error {
    case Internal(String)
    case DrugNameEmpty
    case DrugDozeEmpty
    case DrugDozeIncorectValue
    case DrugEndDateEmpty
    case IncorrectEmailInput
    case ICloidBackupSyncError
    case EmailBackupSendError
    case ICloudIsUnavailable
    
    var localizedDescription: String {
        switch self {
        case .Internal(let value):
            return value
        case .DrugNameEmpty:
            return NSLocalizedString("Не заполнено название препарата", comment: "")
        case .DrugDozeEmpty:
            return NSLocalizedString("Не заполнена доза препарата", comment: "")
        case .DrugDozeIncorectValue:
            return NSLocalizedString("Значение дозировки должны быть от 0 до 2 000", comment: "")
        case .DrugEndDateEmpty:
            return NSLocalizedString("Укажите время окончания курса или сделайте его ежедневным", comment: "")
        case .IncorrectEmailInput:
            return NSLocalizedString("Введене некорректный e-mail. Пожалуйста, попробуйте снова", comment: "")
        case .ICloidBackupSyncError:
            return NSLocalizedString("Ошибка отправки резервной копии в iCloud", comment: "")
        case .EmailBackupSendError:
            return NSLocalizedString("Ошибка отправки резервной копии на Email", comment: "")
        case .ICloudIsUnavailable:
            return NSLocalizedString("Невозможно получить доступ к хранилищу iCloud. Пожалуйста, проверьте Настройки", comment: "")
        }
    }
}
