defmodule ExRatatui.Widgets.WidgetListTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Style
  alias ExRatatui.Widgets.{Block, Checkbox, Markdown, Paragraph, WidgetList}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "WidgetList widget" do
    test "renders list of paragraphs", %{terminal: terminal} do
      wl = %WidgetList{
        items: [
          {%Paragraph{text: "Message 1"}, 1},
          {%Paragraph{text: "Message 2"}, 1},
          {%Paragraph{text: "Message 3"}, 1}
        ]
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Message 1"
      assert content =~ "Message 2"
      assert content =~ "Message 3"
    end

    test "renders mixed widget types", %{terminal: terminal} do
      wl = %WidgetList{
        items: [
          {%Paragraph{text: "A paragraph"}, 1},
          {%Checkbox{label: "Check me", checked: true}, 1}
        ]
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "A paragraph"
      assert content =~ "Check me"
    end

    test "renders with selection", %{terminal: terminal} do
      wl = %WidgetList{
        items: [
          {%Paragraph{text: "Item A"}, 1},
          {%Paragraph{text: "Item B"}, 1}
        ],
        selected: 0,
        highlight_style: %Style{bg: :blue}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Item A"
    end

    test "renders with block", %{terminal: terminal} do
      wl = %WidgetList{
        items: [{%Paragraph{text: "Content"}, 1}],
        block: %Block{title: "Messages", borders: [:all]}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Messages"
      assert content =~ "Content"
    end

    test "renders empty list", %{terminal: terminal} do
      wl = %WidgetList{items: []}
      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
    end

    test "renders with scroll_offset and clips hidden items", %{terminal: terminal} do
      wl = %WidgetList{
        items: [
          {%Paragraph{text: "Hidden"}, 1},
          {%Paragraph{text: "Visible"}, 1}
        ],
        scroll_offset: 1
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Visible"
      refute content =~ "Hidden"
    end

    test "renders variable-height items", %{terminal: terminal} do
      wl = %WidgetList{
        items: [
          {%Paragraph{text: "Short"}, 1},
          {%Paragraph{text: "Tall item\nLine 2\nLine 3"}, 3},
          {%Paragraph{text: "After tall"}, 1}
        ]
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Short"
      assert content =~ "Tall item"
      assert content =~ "After tall"
    end

    test "scroll_offset with selection", %{terminal: terminal} do
      wl = %WidgetList{
        items: [
          {%Paragraph{text: "Scrolled past"}, 1},
          {%Paragraph{text: "Selected item"}, 1},
          {%Paragraph{text: "Third"}, 1}
        ],
        scroll_offset: 1,
        selected: 1,
        highlight_style: %Style{bg: :blue}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Selected item"
      refute content =~ "Scrolled past"
    end

    test "renders markdown items", %{terminal: terminal} do
      wl = %WidgetList{
        items: [
          {%Markdown{content: "**Bold** text"}, 2},
          {%Markdown{content: "- item1\n- item2"}, 3}
        ]
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Bold"
      assert content =~ "item1"
    end

    test "row-based scroll_offset walks through every position", %{terminal: terminal} do
      # Item 1: 3 rows ("Line 1", "Line 2", "Line 3")
      # Item 2: 2 rows ("Line 4", "Line 5")
      # Total content: 5 rows, viewport: 3 rows
      items = [
        {%Paragraph{text: "Line 1\nLine 2\nLine 3"}, 3},
        {%Paragraph{text: "Line 4\nLine 5"}, 2}
      ]

      rect = %Rect{x: 0, y: 0, width: 40, height: 3}

      # offset 0 → Lines 1, 2, 3
      wl = %WidgetList{items: items, scroll_offset: 0}
      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Line 1"
      assert content =~ "Line 2"
      assert content =~ "Line 3"
      refute content =~ "Line 4"
      refute content =~ "Line 5"

      # offset 1 → clips first row of item 1 → Lines 2, 3, 4
      wl = %WidgetList{items: items, scroll_offset: 1}
      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      refute content =~ "Line 1"
      assert content =~ "Line 2"
      assert content =~ "Line 3"
      assert content =~ "Line 4"
      refute content =~ "Line 5"

      # offset 2 → clips two rows of item 1 → Lines 3, 4, 5
      wl = %WidgetList{items: items, scroll_offset: 2}
      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      refute content =~ "Line 1"
      refute content =~ "Line 2"
      assert content =~ "Line 3"
      assert content =~ "Line 4"
      assert content =~ "Line 5"

      # offset 3 → item 1 fully scrolled past → Lines 4, 5 + empty
      wl = %WidgetList{items: items, scroll_offset: 3}
      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      refute content =~ "Line 1"
      refute content =~ "Line 2"
      refute content =~ "Line 3"
      assert content =~ "Line 4"
      assert content =~ "Line 5"

      # offset 4 → clips first row of item 2 → Line 5 + empty
      wl = %WidgetList{items: items, scroll_offset: 4}
      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      refute content =~ "Line 1"
      refute content =~ "Line 2"
      refute content =~ "Line 3"
      refute content =~ "Line 4"
      assert content =~ "Line 5"

      # offset 5 → past all content → empty
      wl = %WidgetList{items: items, scroll_offset: 5}
      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      refute content =~ "Line 1"
      refute content =~ "Line 2"
      refute content =~ "Line 3"
      refute content =~ "Line 4"
      refute content =~ "Line 5"
    end

    test "scroll_offset past all content does not panic", %{terminal: terminal} do
      wl = %WidgetList{
        items: [
          {%Paragraph{text: "First"}, 1},
          {%Paragraph{text: "Second"}, 1}
        ],
        scroll_offset: 100
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      refute content =~ "First"
      refute content =~ "Second"
    end

    test "scroll_offset with selection highlights correct item across clipping", %{
      terminal: terminal
    } do
      # Item 0: 2 rows, Item 1: 2 rows — scroll by 1 row so item 0 is partially
      # clipped and item 1 (selected) is fully visible
      wl = %WidgetList{
        items: [
          {%Paragraph{text: "Top\nBottom"}, 2},
          {%Paragraph{text: "Selected A\nSelected B"}, 2}
        ],
        scroll_offset: 1,
        selected: 1,
        highlight_style: %Style{bg: :blue}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 3}

      assert :ok = ExRatatui.draw(terminal, [{wl, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      refute content =~ "Top"
      assert content =~ "Bottom"
      assert content =~ "Selected A"
      assert content =~ "Selected B"
    end

    test "widget_list struct has correct defaults" do
      wl = %WidgetList{}
      assert wl.items == []
      assert wl.selected == nil
      assert wl.scroll_offset == 0
      assert wl.block == nil
      assert wl.style == %Style{}
      assert wl.highlight_style == %Style{}
    end
  end
end
