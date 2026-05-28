defmodule ExRatatui.Event do
  @moduledoc """
  Terminal event structs.

  Events are returned by `ExRatatui.poll_event/1` and can be pattern matched
  to handle user input:

    * `ExRatatui.Event.Key` — keyboard events (key presses, releases, repeats)
    * `ExRatatui.Event.Mouse` — mouse events (clicks, scrolls, drags)
    * `ExRatatui.Event.Resize` — terminal resize events
    * `ExRatatui.Event.Paste` — bracketed paste events (requires bracketed paste mode enabled)

  ## Example

      case ExRatatui.poll_event(timeout) do
        %ExRatatui.Event.Key{code: "q"} -> :quit
        %ExRatatui.Event.Key{code: "up"} -> :scroll_up
        %ExRatatui.Event.Mouse{kind: "scroll_down"} -> :scroll_down
        %ExRatatui.Event.Resize{width: w, height: h} -> {:resize, w, h}
        %ExRatatui.Event.Paste{content: text} -> {:paste, text}
        nil -> :no_event
      end
  """

  @type t ::
          ExRatatui.Event.Key.t()
          | ExRatatui.Event.Mouse.t()
          | ExRatatui.Event.Resize.t()
          | ExRatatui.Event.Paste.t()
end

defmodule ExRatatui.Event.Paste do
  @moduledoc """
  A bracketed paste event carrying the full pasted string.

  Delivered when the terminal is in bracketed paste mode (`\\e[?2004h`) and
  the user pastes content (e.g. Cmd+V on macOS). The `content` field holds
  the complete pasted text as a single string — newlines and special
  characters are preserved exactly as pasted.
  """

  @type t :: %__MODULE__{content: String.t()}
  defstruct [:content]
end
