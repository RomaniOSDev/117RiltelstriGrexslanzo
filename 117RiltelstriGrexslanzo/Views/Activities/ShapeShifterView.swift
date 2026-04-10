//
//  ShapeShifterView.swift
//  117RiltelstriGrexslanzo
//
//  Created by Bennetted Warddd on 30.03.2026.
//

import SwiftUI

struct WharfSnapPlayView: View {
    let context: ActivityContext
    let onFinish: (ActivityResultData) -> Void

    @StateObject private var viewModel: WharfSnapSession

    init(context: ActivityContext, onFinish: @escaping (ActivityResultData) -> Void) {
        self.context = context
        self.onFinish = onFinish
        _viewModel = StateObject(wrappedValue: WharfSnapSession(difficulty: context.difficulty, level: context.level))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                GeometryReader { geo in
                    ZStack {
                        targetLayout(in: geo.size)
                        draggablePieces(in: geo.size)
                    }
                    .appPlayfield(cornerRadius: 18)
                    .onAppear {
                        let y = geo.size.height * 0.30
                        let points = stride(from: 0, to: viewModel.pieces.count, by: 1).map { i in
                            CGPoint(x: geo.size.width * (0.18 + Double(i) * 0.16), y: y + CGFloat((i % 2) * 60))
                        }
                        viewModel.setupTargets(points)
                    }
                }
                .frame(height: 360)

                Button("Seal the Dock") {
                    viewModel.forceFinish()
                    onFinish(viewModel.result())
                }
                .buttonStyle(.plain)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
                .frame(maxWidth: .infinity, minHeight: 52)
                .appProminentFill(cornerRadius: 14)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .appScreenBackdrop()
        .navigationTitle(ActivityKind.wharfSnap.title)
        .onChange(of: viewModel.isFinished) { _, done in
            if done { onFinish(viewModel.result()) }
        }
    }

    private var header: some View {
        HStack {
            Text("Clock: \(viewModel.timeRemaining)s")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Text(context.difficulty.title)
                .font(.subheadline.bold())
                .foregroundStyle(Color.appAccent)
        }
        .padding()
        .appPanel(cornerRadius: 14, elevated: true)
    }

    private func targetLayout(in size: CGSize) -> some View {
        ForEach(Array(viewModel.pieces.enumerated()), id: \.element.id) { index, piece in
            if index < viewModel.targets.count {
                shapeView(for: piece.shape)
                    .strokeBorder(Color.appAccent.opacity(0.7), style: StrokeStyle(lineWidth: 3, dash: [6]))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(piece.targetAngle))
                    .position(viewModel.targets[index])
            }
        }
    }

    private func draggablePieces(in size: CGSize) -> some View {
        ForEach(Array(viewModel.pieces.enumerated()), id: \.element.id) { index, piece in
            let column = index % 3
            let row = index / 3
            let startPosition = CGPoint(
                x: size.width * (0.2 + Double(column) * 0.28),
                y: size.height * (0.72 + Double(row) * 0.18)
            )
            DraggableWharfTile(
                piece: piece,
                target: viewModel.targets.indices.contains(index) ? viewModel.targets[index] : .zero,
                isHard: context.difficulty == .hard,
                startPosition: startPosition
            ) { updated in
                viewModel.updatePiece(updated)
            }
        }
    }

    private func shapeView(for form: WharfGlyphKind) -> some InsettableShape {
        switch form {
        case .circle: return AnyInsettableShape(Circle())
        case .square: return AnyInsettableShape(RoundedRectangle(cornerRadius: 10))
        case .triangle: return AnyInsettableShape(TriangleShape())
        }
    }
}

private struct DraggableWharfTile: View {
    @State var piece: WharfTile
    let target: CGPoint
    let isHard: Bool
    let startPosition: CGPoint
    let onUpdate: (WharfTile) -> Void

    var body: some View {
        shapeView(for: piece.shape)
            .fill(piece.isPlaced ? Color.appAccent : Color.appPrimary)
            .frame(width: 62, height: 62)
            .overlay(shapeView(for: piece.shape).stroke(Color.appTextPrimary, lineWidth: 2))
            .rotationEffect(.degrees(piece.angle))
            .offset(piece.offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard !piece.isPlaced else { return }
                        piece.offset = value.translation
                    }
                    .onEnded { _ in
                        guard !piece.isPlaced else { return }
                        let finalPoint = CGPoint(x: startPosition.x + piece.offset.width, y: startPosition.y + piece.offset.height)
                        let closeEnough = hypot(finalPoint.x - target.x, finalPoint.y - target.y) < 55
                        let angleOK = !isHard || abs(piece.angle - piece.targetAngle) < 20
                        if closeEnough && angleOK {
                            piece.offset = CGSize(width: target.x - startPosition.x, height: target.y - startPosition.y)
                            piece.isPlaced = true
                        }
                        onUpdate(piece)
                    }
            )
            .simultaneousGesture(
                RotationGesture()
                    .onChanged { value in
                        guard !piece.isPlaced else { return }
                        piece.angle = value.degrees
                    }
            )
            .position(startPosition)
    }

    private func shapeView(for form: WharfGlyphKind) -> some Shape {
        switch form {
        case .circle: return AnyShape(Circle())
        case .square: return AnyShape(RoundedRectangle(cornerRadius: 10))
        case .triangle: return AnyShape(TriangleShape())
        }
    }
}

private struct TriangleShape: InsettableShape {
    private var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: insetAmount, dy: insetAmount)
        guard r.width > 0, r.height > 0 else { return Path() }
        var path = Path()
        path.move(to: CGPoint(x: r.midX, y: r.minY))
        path.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        path.addLine(to: CGPoint(x: r.minX, y: r.maxY))
        path.closeSubpath()
        return path
    }

    func inset(by amount: CGFloat) -> TriangleShape {
        TriangleShape(insetAmount: insetAmount + amount)
    }
}

private struct AnyShape: Shape {
    private let builder: (CGRect) -> Path
    init<S: Shape>(_ shape: S) { builder = { rect in shape.path(in: rect) } }
    func path(in rect: CGRect) -> Path { builder(rect) }
}

private struct AnyInsettableShape: InsettableShape {
    private let builder: (CGRect) -> Path
    init<S: InsettableShape>(_ shape: S) { builder = { rect in shape.path(in: rect) } }
    func path(in rect: CGRect) -> Path { builder(rect) }
    func inset(by amount: CGFloat) -> some InsettableShape { self }
}
