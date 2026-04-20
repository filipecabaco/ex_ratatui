defmodule ExRatatui.Widgets.PopupTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Widgets.{Block, List, Markdown, Paragraph, Popup}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "Popup widget" do
    test "renders popup with paragraph content", %{terminal: terminal} do
      popup = %Popup{
        content: %Paragraph{text: "Hello from popup"},
        percent_width: 80,
        percent_height: 80
      }

      rect = %Rect{x: 0, y: 0, width: 60, height: 15}

      assert :ok = ExRatatui.draw(terminal, [{popup, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Hello from popup"
    end

    test "popup clears background area", %{terminal: terminal} do
      rect = %Rect{x: 0, y: 0, width: 60, height: 15}

      # Fill every cell with X (wrap: true to fill all rows)
      bg = %Paragraph{text: String.duplicate("X", 60 * 15), wrap: true}
      assert :ok = ExRatatui.draw(terminal, [{bg, rect}])
      content_before = ExRatatui.get_buffer_content(terminal)
      x_count_before = content_before |> String.graphemes() |> Enum.count(&(&1 == "X"))
      assert x_count_before > 0

      # Now draw popup on top — it should clear its region
      popup = %Popup{
        content: %Paragraph{text: "Popup"},
        percent_width: 80,
        percent_height: 80
      }

      assert :ok = ExRatatui.draw(terminal, [{bg, rect}, {popup, rect}])
      content_after = ExRatatui.get_buffer_content(terminal)
      assert content_after =~ "Popup"

      x_count_after = content_after |> String.graphemes() |> Enum.count(&(&1 == "X"))

      assert x_count_after < x_count_before,
             "Popup should clear background Xs. Before: #{x_count_before}, After: #{x_count_after}"
    end

    test "popup with block border", %{terminal: terminal} do
      popup = %Popup{
        content: %Paragraph{text: "Content"},
        block: %Block{title: "Dialog", borders: [:all], border_type: :rounded},
        percent_width: 70,
        percent_height: 70
      }

      rect = %Rect{x: 0, y: 0, width: 60, height: 15}

      assert :ok = ExRatatui.draw(terminal, [{popup, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Dialog"
    end

    test "popup with list content", %{terminal: terminal} do
      popup = %Popup{
        content: %List{items: ["Option A", "Option B", "Option C"]},
        percent_width: 60,
        percent_height: 60
      }

      rect = %Rect{x: 0, y: 0, width: 60, height: 15}

      assert :ok = ExRatatui.draw(terminal, [{popup, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Option A"
      assert content =~ "Option B"
    end

    test "popup with fixed dimensions", %{terminal: terminal} do
      popup = %Popup{
        content: %Paragraph{text: "Fixed"},
        fixed_width: 20,
        fixed_height: 5
      }

      rect = %Rect{x: 0, y: 0, width: 60, height: 15}

      assert :ok = ExRatatui.draw(terminal, [{popup, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Fixed"
    end

    test "popup with markdown content", %{terminal: terminal} do
      popup = %Popup{
        content: %Markdown{content: "# Hello\n\nSome **bold** text."},
        percent_width: 80,
        percent_height: 80
      }

      rect = %Rect{x: 0, y: 0, width: 60, height: 15}

      assert :ok = ExRatatui.draw(terminal, [{popup, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Hello"
    end

    test "popup with nil content raises ArgumentError", %{terminal: terminal} do
      popup = %Popup{}
      rect = %Rect{x: 0, y: 0, width: 60, height: 15}

      assert_raise ArgumentError, ~r/Popup :content is required/, fn ->
        ExRatatui.draw(terminal, [{popup, rect}])
      end
    end

    test "popup struct has correct defaults" do
      popup = %Popup{}
      assert popup.content == nil
      assert popup.block == nil
      assert popup.percent_width == 60
      assert popup.percent_height == 60
      assert popup.fixed_width == nil
      assert popup.fixed_height == nil
    end
  end
end
