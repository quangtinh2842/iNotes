//
//  ResourcesView.swift
//  iNotes
//
//  Created by Soren Inis Ngo on 03/04/2026.
//

import SwiftUI

struct ResourcesView: View {
  
  var body: some View {
    VStack {
      List(ResourcesStore.resources, id: \.self) { resource in
        Text(resource)
      }
    }
    .navigationTitle("Resources")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.visible, for: .navigationBar)
  }
}

struct ResourcesView_Previews: PreviewProvider {
  static var previews: some View {
    ResourcesView()
  }
}
