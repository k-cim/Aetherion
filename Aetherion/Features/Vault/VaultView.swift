// === File: VaultView.swift
// Version: 1.0
// Date: 2025-08-29 20:45:00 UTC
// Description: SwiftUI view for Vault feature. Displays secured items.
// Author: K-Cim

import SwiftUI

struct VaultView: View {
    @StateObject private var vm = VaultViewModel()

    var body: some View {
        List {
            if vm.items.isEmpty {
                ContentUnavailableView(
                    "Vault is empty",
                    systemImage: "lock",
                    description: Text("Add items to the vault for testing.")
                )
            } else {
                ForEach(vm.items, id: \.self) { it in
                    HStack {
                        Image(systemName: "doc.text")
                        Text(it)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Vault")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { vm.addSample() } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
    }
}

#Preview { VaultView() }
