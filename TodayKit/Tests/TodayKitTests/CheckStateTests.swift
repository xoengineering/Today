import Testing
import TodayKit

@Suite struct CheckStateTests {
  @Test func nextStepsForwardAndStopsAtDone() {
    #expect(CheckState.todo.next == .doing)
    #expect(CheckState.doing.next == .done)
    #expect(CheckState.done.next == .done)
  }

  @Test func previousStepsBackAndStopsAtToDo() {
    #expect(CheckState.done.previous == .doing)
    #expect(CheckState.doing.previous == .todo)
    #expect(CheckState.todo.previous == .todo)
  }
}
