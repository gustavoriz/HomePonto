//
//  ContentView.swift
//  HomePonto
//
//  Created by Gustavo on 13/06/24.
//
 
import SwiftUI

struct WorkRecord: Identifiable, Codable {
    var id = UUID()
    var selectedDate: Date
    var entryTime: Date?
    var lunchOutTime: Date?
    var lunchInTime: Date?
    var exitTime: Date?
    var realExitTime: Date?
    var extraHours: TimeInterval?
}

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var entryTime: Date?
    @State private var lunchOutTime: Date?
    @State private var lunchInTime: Date?
    @State private var realExitTime: Date?
    @State private var exitTime: Date?
    @State private var extraHours: TimeInterval?
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false
    @State private var activePicker: PickerType?
    @State private var records: [WorkRecord] = []

    enum PickerType {
        case date, entry, lunchOut, lunchIn, realExit
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Image("HomePonto")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.7)
                        .padding(.top, 20)

                    Group {
                        Button(action: {
                            activePicker = .date
                            showingDatePicker = true
                        }) {
                            Text("Data: \(selectedDate, formatter: dateFormatter)")
                                .padding()
                                .frame(width: geometry.size.width * 0.9, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }

                        Button(action: {
                            activePicker = .entry
                            showingTimePicker = true
                            entryTime = entryTime ?? Date()
                        }) {
                            Text("Entrada: \(entryTime != nil ? timeFormatter.string(from: entryTime!) : "Selecionar...")")
                                .padding()
                                .frame(width: geometry.size.width * 0.9, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }

                        Button(action: {
                            activePicker = .lunchOut
                            showingTimePicker = true
                            lunchOutTime = lunchOutTime ?? Date()
                        }) {
                            Text("Saída para Almoço: \(lunchOutTime != nil ? timeFormatter.string(from: lunchOutTime!) : "Selecionar...")")
                                .padding()
                                .frame(width: geometry.size.width * 0.9, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }

                        Button(action: {
                            activePicker = .lunchIn
                            showingTimePicker = true
                            lunchInTime = lunchInTime ?? Date()
                        }) {
                            Text("Retorno do Almoço: \(lunchInTime != nil ? timeFormatter.string(from: lunchInTime!) : "Selecionar...")")
                                .padding()
                                .frame(width: geometry.size.width * 0.9, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }
                        
                        Button(action: {
                            activePicker = .realExit
                            showingTimePicker = true
                            realExitTime = realExitTime ?? Date()
                        }) {
                            Text("Saída Real: \(realExitTime != nil ? timeFormatter.string(from: realExitTime!) : "Selecionar...")")
                                .padding()
                                .frame(width: geometry.size.width * 0.9, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    if let exitTime = exitTime {
                        Text("Horário que você deveria sair: \(exitTime, formatter: timeFormatter)")
                            .padding()
                    }

                    if let extraHours = extraHours {
                        let hours = Int(extraHours) / 3600
                        let minutes = (Int(extraHours) % 3600) / 60
                        Text("Horas Extras: \(hours) horas e \(minutes) minutos")
                    }
                    
                    HStack(spacing: 10) {
                        Button("Salvar Registro") {
                            calculateExitTime()
                            saveData()
                        }
                        .padding()
                        .background(Color(red: 101 / 255, green: 168 / 255, blue: 159 / 255))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        .frame(width: (geometry.size.width * 0.3) - 10, alignment: .leading)

                        Button("Novo Registro"){
                            clearFields()
                        }
                        .padding()
                        .background(Color(red: 101 / 255, green: 138 / 255, blue: 168 / 255))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        .frame(width: (geometry.size.width * 0.3) - 10, alignment: .leading)
                        
                        Button("Horário Saída") {
                            calculateExitTime()
                        }
                        .padding()
                        .background(Color(red: 168 / 255, green: 144 / 255, blue: 101 / 255))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                        .frame(width: (geometry.size.width * 0.28) - 10, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)

                    NavigationLink(destination: HistoryView(records: $records)) {
                        Text("Ver o Histórico de Registros Realizados")
                            .padding()
                            .background(Color(red: 136 / 255, green: 101 / 255, blue: 168 / 255))
                            .foregroundColor(.white)
                            .cornerRadius(5)
                            .frame(width: geometry.size.width * 0.9, alignment: .center)
                    }
                    .frame(maxWidth: .infinity)
                }
                .sheet(isPresented: $showingDatePicker) {
                    if activePicker == .date {
                        DatePicker("Selecione a Data", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                    }
                }
                .sheet(isPresented: $showingTimePicker) {
                    if activePicker != .date {
                        DatePicker("Selecione o Horário", selection: binding(for: activePicker), displayedComponents: .hourAndMinute)
                            .datePickerStyle(WheelDatePickerStyle())
                            .padding()
                    }
                }
                .padding()
                .onAppear(perform: loadData)
            }
        }
    }

    private func clearFields() {
        selectedDate = Date()
        entryTime = nil
        lunchOutTime = nil
        lunchInTime = nil
        realExitTime = nil
        exitTime = nil
        extraHours = nil
    }

    private func binding(for pickerType: PickerType?) -> Binding<Date> {
        switch pickerType {
        case .entry:
            return Binding(
                get: { entryTime ?? Date() },
                set: { entryTime = $0 }
            )
        case .lunchOut:
            return Binding(
                get: { lunchOutTime ?? Date() },
                set: { lunchOutTime = $0 }
            )
        case .lunchIn:
            return Binding(
                get: { lunchInTime ?? Date() },
                set: { lunchInTime = $0 }
            )
        case .realExit:
            return Binding(
                get: { realExitTime ?? Date() },
                set: { realExitTime = $0 }
            )
        default:
            return Binding(
                get: { entryTime ?? Date() },
                set: { entryTime = $0 }
            )
        }
    }

    private func calculateExitTime() {
        let workHours: TimeInterval = 8 * 3600 // 8 horas em segundos
        let tolerance: TimeInterval = 10 * 60 // 10 minutos em segundos

        // Calculando a duração do almoço
        guard let lunchOutTime = lunchOutTime, let lunchInTime = lunchInTime, let entryTime = entryTime else {
            // Garantir que todos os tempos necessários estão disponíveis
            return
        }

        let lunchDuration = lunchInTime.timeIntervalSince(lunchOutTime)

        // Tempo total de trabalho
        let totalWorkTime = workHours + lunchDuration

        // Calcular horário de saída
        exitTime = entryTime.addingTimeInterval(totalWorkTime)

        // Ajustar horário de saída, se necessário
        if let realExitTime = realExitTime {
            let totalWorkedTime = realExitTime.timeIntervalSince(entryTime)
            extraHours = totalWorkedTime - totalWorkTime
            
            // Aplicar tolerância de 10 minutos
            if extraHours! >= -tolerance && extraHours! <= (tolerance + 60) {
                extraHours = 0
            }
            if extraHours! <= -tolerance {
                extraHours! = extraHours! - 60
            }
        } else {
            extraHours = 0
        }
    }

    private func saveData() {
        // Verificar se já existe um registro para a data selecionada
        if let index = records.firstIndex(where: { Calendar.current.isDate($0.selectedDate, inSameDayAs: selectedDate) }) {
            // Atualizar registro existente
            records[index].entryTime = entryTime
            records[index].lunchOutTime = lunchOutTime
            records[index].lunchInTime = lunchInTime
            records[index].exitTime = exitTime
            records[index].realExitTime = realExitTime
            records[index].extraHours = extraHours
        } else {
            // Criar novo registro
            let newRecord = WorkRecord(
                selectedDate: selectedDate,
                entryTime: entryTime,
                lunchOutTime: lunchOutTime,
                lunchInTime: lunchInTime,
                exitTime: exitTime,
                realExitTime: realExitTime,
                extraHours: extraHours
            )
            records.append(newRecord)
        }

        let userDefaults = UserDefaults.standard
        if let encoded = try? JSONEncoder().encode(records) {
            userDefaults.set(encoded, forKey: "records")
        }
    }

    private func loadData() {
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.data(forKey: "records"),
           let decoded = try? JSONDecoder().decode([WorkRecord].self, from: data) {
            records = decoded

            // Verificar se há um registro para a data de hoje
            if let todayRecord = records.first(where: { Calendar.current.isDate($0.selectedDate, inSameDayAs: Date()) }) {
                selectedDate = todayRecord.selectedDate
                entryTime = todayRecord.entryTime
                lunchOutTime = todayRecord.lunchOutTime
                lunchInTime = todayRecord.lunchInTime
                exitTime = todayRecord.exitTime
                realExitTime = todayRecord.realExitTime
                extraHours = todayRecord.extraHours
            }
        }
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct HistoryView: View {
    @Binding var records: [WorkRecord]
    @State private var selectedRecord: WorkRecord?
    @State private var selectedMonth = Date()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                DatePicker("Selecione o Mês", selection: $selectedMonth, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                
                Button("Gerar .CSV") {
                    exportToCSV()
                }
                .padding()
                .background(Color(red: 136 / 255, green: 101 / 255, blue: 168 / 255))
                .foregroundColor(.white)
                .cornerRadius(5)
                
                Button("Voltar") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(5)
            }
            .padding()

            var formattedTotalExtraHours: String {
                let totalSeconds = Int(totalExtraHours)
                let hours = totalSeconds / 3600
                let minutes = (totalSeconds % 3600) / 60
                return "\(hours) horas e \(minutes) minutos"
            }
            
            List {
                ForEach(filteredRecords) { record in
                    VStack(alignment: .leading) {
                        Text("Data: \(record.selectedDate, formatter: dateFormatter)")
                        if let entryTime = record.entryTime {
                            Text("Entrada: \(entryTime, formatter: timeFormatter)")
                        }
                        if let lunchOutTime = record.lunchOutTime {
                            Text("Saída para Almoço: \(lunchOutTime, formatter: timeFormatter)")
                        }
                        if let lunchInTime = record.lunchInTime {
                            Text("Retorno do Almoço: \(lunchInTime, formatter: timeFormatter)")
                        }
                        if let exitTime = record.exitTime {
                            Text("Saída: \(exitTime, formatter: timeFormatter)")
                        }
                        if let realExitTime = record.realExitTime {
                            Text("Saída Real: \(realExitTime, formatter: timeFormatter)")
                        }
                        if let extraHours = record.extraHours {
                            Text("Horas Extras: \(extraHours / 3600, specifier: "%.2f") horas")
                            Text("Horas Extras: \(Int(extraHours) / 3600) horas e \((Int(extraHours) % 3600) / 60) minutos")
                        }
                    }
                    .padding()
                    .onTapGesture {
                        selectedRecord = record
                    }
                }
                .onDelete { indexSet in
                    records.remove(atOffsets: indexSet)
                    saveRecords()
                }
            }

            Text("Total de Horas Extras: \(formattedTotalExtraHours)")
                .padding()
        }
        .sheet(item: $selectedRecord) { record in
            EditRecordView(record: record) { updatedRecord in
                if let index = records.firstIndex(where: { $0.id == record.id }) {
                    records[index] = updatedRecord
                    saveRecords()
                    // Recalcular horas extras
                    records[index].extraHours = calculateExtraHours(for: records[index])
                }
            }
        }
    }

    private func exportToCSV() {
        // Preparar os dados no formato CSV
        var csvText = "Data,Entrada,Saída para Almoço,Retorno do Almoço,Saída Real,Horas Extras\n"
        
        for record in records {
            let rowData = "\(dateFormatter.string(from: record.selectedDate)),\(record.entryTime != nil ? timeFormatter.string(from: record.entryTime!) : ""),\(record.lunchOutTime != nil ? timeFormatter.string(from: record.lunchOutTime!) : ""),\(record.lunchInTime != nil ? timeFormatter.string(from: record.lunchInTime!) : ""),\(record.realExitTime != nil ? timeFormatter.string(from: record.realExitTime!) : ""),\(record.extraHours != nil ? String(format: "%.2f", record.extraHours! / 3600) : "")\n"
            csvText.append(rowData)
        }
        
        // Escrever o CSV em um arquivo
        do {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent("HistoricoRegistros.csv")
            
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            
            print("Arquivo CSV salvo em: \(fileURL)")
            
            // Opcional: Mostrar uma folha de compartilhamento para o usuário enviar o arquivo
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            if let topController = UIApplication.shared.keyWindow?.rootViewController {
                topController.present(activityVC, animated: true, completion: nil)
            }
            
        } catch {
            print("Erro ao criar o arquivo CSV: \(error)")
        }
    }

    private func saveRecords() {
        let userDefaults = UserDefaults.standard
        if let encoded = try? JSONEncoder().encode(records) {
            userDefaults.set(encoded, forKey: "records")
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    private func calculateExtraHours(for record: WorkRecord) -> TimeInterval {
        let workHours: TimeInterval = 8 * 3600 // 8 horas em segundos
        let tolerance: TimeInterval = 10 * 60 // 10 minutos em segundos
        
        guard let entryTime = record.entryTime, let lunchOutTime = record.lunchOutTime, let lunchInTime = record.lunchInTime, let realExitTime = record.realExitTime else {
            return 0
        }

        let lunchDuration = lunchInTime.timeIntervalSince(lunchOutTime)
        let totalWorkTime = workHours + lunchDuration
        let totalWorkedTime = realExitTime.timeIntervalSince(entryTime)
        var extraHours = totalWorkedTime - totalWorkTime

        // Aplicar tolerância de 10 minutos
        if extraHours >= -tolerance && extraHours <= tolerance {
            extraHours = 0
        }

        return extraHours
    }

    var filteredRecords: [WorkRecord] {
        let calendar = Calendar.current
        return records.filter {
            calendar.isDate($0.selectedDate, equalTo: selectedMonth, toGranularity: .month)
        }
    }

    var totalExtraHours: TimeInterval {
        filteredRecords.reduce(0) { $0 + ($1.extraHours ?? 0) }
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct EditRecordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var record: WorkRecord
    var onSave: (WorkRecord) -> Void

    var body: some View {
        VStack {
            DatePicker("Data", selection: $record.selectedDate, displayedComponents: .date)
                .padding()

            DatePicker("Entrada", selection: Binding(
                get: { record.entryTime ?? Date() },
                set: { record.entryTime = $0 }
            ), displayedComponents: .hourAndMinute)
                .padding()

            DatePicker("Saída para Almoço", selection: Binding(
                get: { record.lunchOutTime ?? Date() },
                set: { record.lunchOutTime = $0 }
            ), displayedComponents: .hourAndMinute)
                .padding()

            DatePicker("Retorno do Almoço", selection: Binding(
                get: { record.lunchInTime ?? Date() },
                set: { record.lunchInTime = $0 }
            ), displayedComponents: .hourAndMinute)
                .padding()

            DatePicker("Saída Real", selection: Binding(
                get: { record.realExitTime ?? Date() },
                set: { record.realExitTime = $0 }
            ), displayedComponents: .hourAndMinute)
                .padding()

            Button("Salvar") {
                onSave(record)
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(5)
            
            Button("Voltar") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(5)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
