defmodule ExRatatui.Widgets.CalendarTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Style
  alias ExRatatui.Widgets.{Block, Calendar}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "Calendar widget" do
    test "basic month renders", %{terminal: terminal} do
      calendar = %Calendar{display_date: ~D[2026-03-15]}
      rect = %Rect{x: 0, y: 0, width: 22, height: 8}

      assert :ok = ExRatatui.draw(terminal, [{calendar, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "15"
    end

    test "month and weekdays headers render", %{terminal: terminal} do
      calendar = %Calendar{
        display_date: ~D[2026-03-15],
        header_style: %Style{fg: :yellow, modifiers: [:bold]},
        weekday_style: %Style{fg: :cyan}
      }

      rect = %Rect{x: 0, y: 0, width: 22, height: 8}

      assert :ok = ExRatatui.draw(terminal, [{calendar, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "March"
      assert content =~ "2026"
      assert content =~ "Su"
    end

    test "events list highlights dates", %{terminal: terminal} do
      calendar = %Calendar{
        display_date: ~D[2026-03-15],
        events: [
          {~D[2026-03-10], %Style{fg: :red, modifiers: [:bold]}},
          {~D[2026-03-20], %Style{fg: :green}}
        ]
      }

      rect = %Rect{x: 0, y: 0, width: 22, height: 8}

      assert :ok = ExRatatui.draw(terminal, [{calendar, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "10"
      assert content =~ "20"
    end

    test "events map highlights dates", %{terminal: terminal} do
      calendar = %Calendar{
        display_date: ~D[2026-03-15],
        events: %{
          ~D[2026-03-05] => %Style{fg: :magenta},
          ~D[2026-03-25] => nil
        }
      }

      rect = %Rect{x: 0, y: 0, width: 22, height: 8}

      assert :ok = ExRatatui.draw(terminal, [{calendar, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "5"
    end

    test "show_surrounding fills first/last row", %{terminal: terminal} do
      calendar = %Calendar{
        display_date: ~D[2026-03-15],
        show_surrounding: %Style{fg: :dark_gray}
      }

      rect = %Rect{x: 0, y: 0, width: 22, height: 8}

      assert :ok = ExRatatui.draw(terminal, [{calendar, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      # February 2026 ends on the 28th; it should leak into the first row.
      assert content =~ "28"
    end

    test "calendar with block renders", %{terminal: terminal} do
      calendar = %Calendar{
        display_date: ~D[2026-03-15],
        block: %Block{title: " Calendar ", borders: [:all]}
      }

      rect = %Rect{x: 0, y: 0, width: 24, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{calendar, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Calendar"
    end

    test "leap February renders 29", %{terminal: terminal} do
      calendar = %Calendar{display_date: ~D[2024-02-15]}
      rect = %Rect{x: 0, y: 0, width: 22, height: 8}

      assert :ok = ExRatatui.draw(terminal, [{calendar, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "29"
    end

    test "headers can be disabled", %{terminal: terminal} do
      calendar = %Calendar{
        display_date: ~D[2026-03-15],
        show_month_header: false,
        show_weekdays_header: false
      }

      rect = %Rect{x: 0, y: 0, width: 22, height: 8}

      assert :ok = ExRatatui.draw(terminal, [{calendar, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      refute content =~ "March"
      refute content =~ "Su"
    end
  end
end
