import Testing
import TodayKit

@Suite struct ItemStateTests {
  @Test func rawValuesAreTheFooterSpelling() {
    #expect(ItemState.todo.rawValue == "todo")
    #expect(ItemState.doing.rawValue == "doing")
  }
}
