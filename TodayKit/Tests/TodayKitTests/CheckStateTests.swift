import Testing
import TodayKit

@Suite struct CheckStateTests {
  @Test func nextAndPreviousAreInverses() {
    for state in CheckState.allCases {
      #expect(state.next.previous == state)
      #expect(state.previous.next == state)
    }
  }

  @Test func nextCyclesForward() {
    #expect(CheckState.todo.next == .doing)
    #expect(CheckState.doing.next == .done)
    #expect(CheckState.done.next == .todo)
  }
}
