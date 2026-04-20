defmodule ExRatatui.Widgets.MixedWidgetsTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Widgets.{Gauge, List, Paragraph}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "mixed widgets in one frame" do
    test "multiple widget types in a single draw call", %{terminal: terminal} do
      widgets = [
        {%Paragraph{text: "Header"}, %Rect{x: 0, y: 0, width: 40, height: 3}},
        {%List{items: ["a", "b"]}, %Rect{x: 0, y: 3, width: 40, height: 5}},
        {%Gauge{ratio: 0.5}, %Rect{x: 0, y: 8, width: 40, height: 1}}
      ]

      assert :ok = ExRatatui.draw(terminal, widgets)
      content = ExRatatui.get_buffer_content(terminal)
      assert content =~ "Header"
      assert content =~ "a"
      assert content =~ "b"
    end
  end
end
