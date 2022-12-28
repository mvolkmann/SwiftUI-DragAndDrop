import SwiftUI

struct ContentView: View {
    @State private var availableBorderColor: Color = .clear
    @State private var cartBorderColor: Color = .clear
    @State private var unselectedItems: [String] = [
        "Apple",
        "Banana",
        "Cherry"
    ]
    @State private var selectedItems: [String] = []

    private let cornerRadius: CGFloat = 10

    private func draggableItem(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 20))
            .padding()
            .background(.white)
            .cornerRadius(10)
            .draggable(text)
        /* This seems to not be used when .draggable is used.
         .onDrag {
             print("got drag")
             return NSItemProvider(object: text as NSItemProviderWriting)
         }
         */
        /*
         // This was an attempt to determine what is being dragged,
         // but the closure gets invoked for all items,
         // not just the one being dragged.
         .draggable(text) {
         print("dragging \(text)")
         return Text(text)
         }
         */
        // TODO: I need to save the text being dragged so I can
        // TODO: add a colored border to the target container.
    }

    private func handleDrop(
        items: [String],
        from: Binding<[String]>,
        to: Binding<[String]>
    ) -> Bool {
        let dropped = items.first!
        // If the item is being dropped into the container
        // where it already resides, don't do anything.
        guard !to.wrappedValue.contains(dropped) else { return false }

        from.wrappedValue.removeAll { item in item == dropped }
        to.wrappedValue.append(dropped)
        to.wrappedValue.sort()
        return true // indicates success
    }

    var body: some View {
        VStack {
            GroupBox(label: Text("Available Items")) {
                HStack {
                    ForEach(unselectedItems, id: \.self) { item in
                        draggableItem(item)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(availableBorderColor)
            )
            .dropDestination(for: String.self) { items, _ in
                handleDrop(
                    items: items,
                    from: $selectedItems,
                    to: $unselectedItems
                )
            } isTargeted: { over in
                // let inCart = selected.contains(
                // availableBorderColor = canDrop ? .green : .clear
                availableBorderColor = over ? .green : .clear
            }

            HStack {
                let size = 20.0
                Image(systemName: "arrow.down")
                    .resizable()
                    .frame(width: size, height: size)
                Text("""
                Long press an item to begin dragging, \
                then drag between these lists.
                """)
                Image(systemName: "arrow.up")
                    .resizable()
                    .frame(width: size, height: size)
            }

            GroupBox(label: Text("Shopping Cart")) {
                HStack {
                    ForEach(selectedItems, id: \.self) { item in
                        draggableItem(item)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(cartBorderColor)
            )
            .dropDestination(for: String.self) { items, _ in
                handleDrop(
                    items: items,
                    from: $unselectedItems,
                    to: $selectedItems
                )
            } isTargeted: { over in
                cartBorderColor = over ? .green : .clear
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
