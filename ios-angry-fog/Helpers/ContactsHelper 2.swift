//
//  ContactsHelper 2.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 29.3.2025.
//



import Contacts

class ContactsHelper {
    static func fetchContactNames() -> [String] {
        let store = CNContactStore()
        var names: [String] = []

        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)

        do {
            try store.enumerateContacts(with: request) { contact, stop in
                let fullName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
                if !fullName.isEmpty {
                    names.append(fullName)
                }
            }
        } catch {
            print("Failed to fetch contacts: \(error.localizedDescription)")
        }

        return names
    }
}
