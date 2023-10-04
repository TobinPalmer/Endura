import Foundation
import SwiftUI

struct DistanceInput: View {
    @Binding var distance: Double

    var body: some View {
        HStack {
            Button(action: {
                distance -= 1
            }) {
                Image(systemName: "minus")
            }
            TextField("Distance", value: Binding(
                get: { distance },
                set: { newValue in
                    distance = Double(newValue)
                }
            ), format: .number)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .fontColor(.primary)
            Button(action: {
                distance += 1
            }) {
                Image(systemName: "plus")
            }
        }
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(26)
    }
}

struct TimeInput: View {
    @Binding var time: Double

    var body: some View {
        HStack(spacing: 0) {
            Picker("Hours", selection: Binding(
                get: { Int(time) },
                set: { newValue in
                    time = Double(newValue)
                }
            )) {
                ForEach(0 ..< 24) { index in
                    Text("\(index)")
                        .tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .clipShape(.rect.offset(x: -16))
            .padding(.trailing, -16)
            Picker("Minutes", selection: Binding(
                get: { Int(time.rounded(toPlaces: 2) / 100) },
                set: { newValue in
                    time = time.rounded() + Double(newValue) / 100
                }
            )) {
                ForEach(0 ..< 60) { index in
                    Text("\(index)")
                        .tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .clipShape(.rect.offset(x: -16))
            .padding(.trailing, -16)
            .clipShape(.rect.offset(x: 16))
            .padding(.leading, -16)
            Picker("Seconds", selection: Binding(
                get: { Int(time.rounded(toPlaces: 2) / 100) },
                set: { newValue in
                    time = time.rounded() + Double(newValue) / 100
                }
            )) {
                ForEach(0 ..< 60) { index in
                    Text("\(index)")
                        .tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .clipShape(.rect.offset(x: 16))
            .padding(.leading, -16)
        }
        .frame(maxHeight: 100)
        .font(.largeTitle)
        .fontWeight(.bold)
        .padding(26)
    }
}
