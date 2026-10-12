import Foundation
import Testing
import TodayKit

@Suite struct NotesFooterTests {
  @Test func splitsBodyAndFooter() throws {
    let notes = try Fixture.text("notes_with_footer")
    let (body, metadata) = NotesFooter.split(notes)
    #expect(body == "Call the dentist about the thing.\nAsk about the cleaning too.")
    #expect(metadata == ItemMetadata(order: 3, state: .doing, days: [LogicalDay(year: 2026, month: 10, day: 11)]))
  }

  @Test func plainNotesHaveNoMetadata() throws {
    let notes = try Fixture.text("notes_without_footer")
    let (body, metadata) = NotesFooter.split(notes)
    #expect(body == "Just a plain note.\nWith two lines.")
    #expect(metadata == nil)
  }

  @Test func footerAloneLeavesAnEmptyBody() throws {
    let notes = try Fixture.text("notes_footer_only")
    let (body, metadata) = NotesFooter.split(notes)
    #expect(body.isEmpty)
    #expect(metadata?.days.map(\.description) == ["2026-10-10", "2026-10-11"])
    #expect(metadata?.order == nil)
  }

  @Test func corruptFooterStaysInTheBody() throws {
    let notes = try Fixture.text("notes_corrupt_footer")
    let (body, metadata) = NotesFooter.split(notes)
    #expect(metadata == nil)
    #expect(body.hasSuffix("\"order\":"))
  }

  @Test func nilAndEmptyNotesAreEmpty() {
    #expect(NotesFooter.split(nil).body.isEmpty)
    #expect(NotesFooter.split("").body.isEmpty)
    #expect(NotesFooter.split(nil).metadata == nil)
  }

  @Test func joinRoundTripsTheFixture() throws {
    let notes = try Fixture.text("notes_with_footer")
    let (body, metadata) = NotesFooter.split(notes)
    let joined = NotesFooter.join(body: body, metadata: metadata)
    #expect(joined == notes.trimmingCharacters(in: .newlines))
  }

  @Test func joinWithoutMetadataReturnsBodyOrNil() {
    #expect(NotesFooter.join(body: "hello\n", metadata: nil) == "hello")
    #expect(NotesFooter.join(body: "", metadata: nil) == nil)
  }

  @Test func joinWithEmptyBodyIsJustTheFooter() {
    let joined = NotesFooter.join(body: "", metadata: ItemMetadata())
    #expect(joined == "today:{\"days\":[],\"state\":\"todo\",\"v\":1}")
  }

  @Test func footerKeysAreSortedForStableDiffs() {
    let metadata = ItemMetadata(order: 0, state: .todo, days: [LogicalDay(year: 2026, month: 1, day: 2)])
    let joined = NotesFooter.join(body: "x", metadata: metadata)
    #expect(joined == "x\ntoday:{\"days\":[\"2026-01-02\"],\"order\":0,\"state\":\"todo\",\"v\":1}")
  }
}
