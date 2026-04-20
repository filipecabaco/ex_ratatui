defmodule ExRatatui.Widgets.ScrollbarTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Widgets.Scrollbar

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "Scrollbar widget" do
    test "vertical scrollbar renders", %{terminal: terminal} do
      scrollbar = %Scrollbar{
        content_length: 100,
        position: 10,
        orientation: :vertical_right
      }

      rect = %Rect{x: 0, y: 0, width: 1, height: 10}

      assert :ok = ExRatatui.draw(terminal, [{scrollbar, rect}])
    end

    test "horizontal scrollbar renders", %{terminal: terminal} do
      scrollbar = %Scrollbar{
        content_length: 200,
        position: 50,
        orientation: :horizontal_bottom
      }

      rect = %Rect{x: 0, y: 0, width: 40, height: 1}

      assert :ok = ExRatatui.draw(terminal, [{scrollbar, rect}])
    end

    test "scrollbar with viewport_content_length", %{terminal: terminal} do
      scrollbar = %Scrollbar{
        content_length: 100,
        position: 0,
        viewport_content_length: 10
      }

      rect = %Rect{x: 0, y: 0, width: 1, height: 15}

      assert :ok = ExRatatui.draw(terminal, [{scrollbar, rect}])
    end

    test "scrollbar with all orientations", %{terminal: terminal} do
      for orientation <- [:vertical_right, :vertical_left, :horizontal_bottom, :horizontal_top] do
        scrollbar = %Scrollbar{content_length: 50, position: 25, orientation: orientation}

        {rect, _desc} =
          case orientation do
            o when o in [:vertical_right, :vertical_left] ->
              {%Rect{x: 0, y: 0, width: 1, height: 10}, "vertical"}

            _ ->
              {%Rect{x: 0, y: 0, width: 40, height: 1}, "horizontal"}
          end

        assert :ok = ExRatatui.draw(terminal, [{scrollbar, rect}])
      end
    end
  end
end
