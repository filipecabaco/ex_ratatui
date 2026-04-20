defmodule ExRatatui.Widgets.BarChartTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Style
  alias ExRatatui.Widgets.{Bar, BarChart, Block}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "BarChart widget" do
    test "basic vertical chart with labels", %{terminal: terminal} do
      chart = %BarChart{
        data: [
          %Bar{label: "Elixir", value: 80},
          %Bar{label: "Rust", value: 95}
        ],
        bar_width: 6,
        bar_gap: 2,
        bar_style: %Style{fg: :cyan}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Elixir"
      assert content =~ "Rust"
    end

    test "horizontal direction", %{terminal: terminal} do
      chart = %BarChart{
        data: [%Bar{label: "Go", value: 60}],
        direction: :horizontal,
        max: 100
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 4}

      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Go"
    end

    test "per-bar style override and text_value", %{terminal: terminal} do
      chart = %BarChart{
        data: [
          %Bar{label: "Default", value: 10},
          %Bar{label: "Red", value: 20, style: %Style{fg: :red}, text_value: "20!"}
        ],
        bar_width: 4,
        bar_style: %Style{fg: :blue},
        max: 30
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 8}

      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "20!"
    end

    test "with block title", %{terminal: terminal} do
      chart = %BarChart{
        data: [%Bar{label: "A", value: 1}],
        block: %Block{title: " Traffic ", borders: [:all]}
      }

      rect = %Rect{x: 0, y: 0, width: 30, height: 8}

      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Traffic"
    end

    test "auto-scales when max is nil", %{terminal: terminal} do
      chart = %BarChart{
        data: [
          %Bar{label: "A", value: 1},
          %Bar{label: "B", value: 100}
        ]
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 8}

      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
    end

    test "empty data list renders", %{terminal: terminal} do
      chart = %BarChart{data: []}
      rect = %Rect{x: 0, y: 0, width: 20, height: 4}

      assert :ok = ExRatatui.draw(terminal, [{chart, rect}])
    end
  end
end
