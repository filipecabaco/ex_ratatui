defmodule ExRatatui.Widgets.ClearTest do
  use ExUnit.Case, async: true

  alias ExRatatui.Layout.Rect
  alias ExRatatui.Native
  alias ExRatatui.Widgets.{Clear, Paragraph}

  setup do
    terminal = ExRatatui.init_test_terminal(60, 15)
    on_exit(fn -> Native.restore_terminal(terminal) end)
    %{terminal: terminal}
  end

  describe "Clear widget" do
    test "clears an area to spaces", %{terminal: terminal} do
      paragraph = %Paragraph{text: "Hello World!"}
      full = %Rect{x: 0, y: 0, width: 40, height: 3}

      assert :ok = ExRatatui.draw(terminal, [{paragraph, full}])
      assert ExRatatui.get_buffer_content(terminal) =~ "Hello World!"

      clear_rect = %Rect{x: 0, y: 0, width: 12, height: 1}

      assert :ok =
               ExRatatui.draw(terminal, [
                 {paragraph, full},
                 {%Clear{}, clear_rect}
               ])

      content = ExRatatui.get_buffer_content(terminal)
      refute String.starts_with?(content, "Hello")
    end

    test "clear struct has no fields" do
      assert %Clear{} == %Clear{}
      assert Map.keys(%Clear{}) == [:__struct__]
    end
  end
end
