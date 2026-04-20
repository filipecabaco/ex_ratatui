defmodule ExRatatui.Widgets.LineGaugeTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Style
  alias ExRatatui.Widgets.{Block, LineGauge}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "LineGauge widget" do
    test "basic line gauge", %{terminal: terminal} do
      lg = %LineGauge{
        ratio: 0.5,
        filled_style: %Style{fg: :green}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{lg, rect}])
    end

    test "line gauge with label and block", %{terminal: terminal} do
      lg = %LineGauge{
        ratio: 0.75,
        label: "75%",
        filled_style: %Style{fg: :blue},
        block: %Block{title: "Download", borders: [:all]}
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 3}

      assert :ok = ExRatatui.draw(terminal, [{lg, rect}])
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "75%"
      assert content =~ "Download"
    end

    test "line gauge with zero ratio", %{terminal: terminal} do
      lg = %LineGauge{ratio: 0.0}
      rect = %Rect{x: 0, y: 0, width: 20, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{lg, rect}])
    end

    test "line gauge with integer ratio coerced to float", %{terminal: terminal} do
      lg = %LineGauge{ratio: 1}
      rect = %Rect{x: 0, y: 0, width: 20, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{lg, rect}])
    end
  end
end
