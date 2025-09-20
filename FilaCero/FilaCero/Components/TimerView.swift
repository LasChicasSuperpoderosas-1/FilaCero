//
//  timerView.swift
//  FilaCero
//
//  Created by Marco de la Puente on 29/08/25.
//


import SwiftUI

struct TimerView: View {

    let startCondition: Bool
    @Binding var stopCondition: Bool
    @State private var seconds: Int

    init(seconds: Int, startCondition: Bool,stopCondition: Binding<Bool>) {
       self._seconds = State(initialValue: seconds)
       self.startCondition = startCondition
        self._stopCondition = stopCondition
        
   }

    var body: some View {
        Text(transformSeconds(from: seconds))
            .onAppear {
                if (startCondition == true){
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                        if (seconds > 0) {
                            seconds -= 1
                        } else {
                            stopCondition.toggle()
                            timer.invalidate()
                        }
                    }
                }
            }
    }

    private func transformSeconds(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

