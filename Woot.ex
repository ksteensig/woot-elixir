defmodule Woot do
  @type client_id :: integer
  @type wchar_id_clock :: integer
  @type wchar_id :: {client_id, wchar_id_clock}
  @type visible :: boolean
  @type char_alpha :: String.t()
  @type wchar :: {wchar_id, visible, char_alpha, wchar_id, wchar_id}
  @type wstring :: [wchar]
  @type operation :: {atom, wchar}

  @spec wchar_beginning :: wchar
  def wchar_beginning() do
    {wchar_id_beginning(), false, ' ', wchar_id_beginning(), wchar_id_ending()}
  end

  @spec wchar_ending :: wchar
  def wchar_ending() do
    {wchar_id_ending(), false, ' ', wchar_id_beginning(), wchar_id_ending()}
  end

  # make wchar invisible
  @spec hide(wchar) :: wchar
  def hide(wc) do
    {a, _, c, d, e} = wc
    {a, false, c, d, e}
  end

  def wchar_id_beginning() do
    {-1, 0}
  end

  def wchar_id_ending() do
    {-1, 1}
  end

  @spec wstring_pos(wstring, wchar_id) :: integer
  def wstring_pos(ws, wid) do
    {id, id_clock} = wid
    Enum.find_index(ws, fn({{i, clock},_,_,_,_}) -> i == id && clock == id_clock end)
  end

  #hacked together
  @spec insert_wc(wstring, integer, char_alpha, wchar_id, wchar_id, wchar_id) :: wstring
  def insert_wc(ws, pos, alpha, id, prev_id, next_id) do
    #visible neighbors of the wchar to be inserted
    wc_p_pos = wstring_pos(ws, prev_id)
    wc_n_pos = wstring_pos(ws, next_id)

    seq = Enum.slice(ws, (wc_p_pos+1)..(wc_n_pos-1))
    wc_pos = count_wc_pos(seq, {id, true, alpha, id, id}, 0) + pos

    {old_p_id, v1, a1, p1, _} = Enum.at(ws, wc_pos)
    {old_n_id, v2, a2, _, n2} = Enum.at(ws, wc_pos+1)

    new_wc_p = {old_p_id, v1, a1, p1, id}
    new_wc_n = {old_n_id, v2, a2, id, n2}

    List.keyreplace(ws, old_p_id, wc_pos, new_wc_p)
    List.keyreplace(ws, old_n_id, wc_pos, new_wc_n)

    List.insert_at(ws, wc_pos, {id, true, alpha, old_p_id, old_n_id})
  end

  defp count_wc_pos([x|xs], wc, pos) do
    if compare_wc_id(x, wc) do
        count_wc_pos(xs, wc, pos+1)
    end
    pos
  end

  defp count_wc_pos([], _, pos) do
    pos
  end

  #if wc1 is after wc2 then false, else true
  @spec compare_wc_id(wchar, wchar) :: boolean
  def compare_wc_id(wc1, wc2) do
    {id1, clock1} = wchar_get_id(wc1)
    {id2, clock2} = wchar_get_id(wc2)

    if id1 < id2 || (id1 == id2 && clock1 < clock2) do
      false
    end

    true
  end

  @spec delete_wc(wstring, wchar) :: wstring
  def delete_wc(ws, wc) do
    pos = wstring_pos(ws, wchar_get_id(wc))
    slice1 = Enum.slice(ws, 0..(pos-1))
    slice2 = Enum.slice(ws, (pos+1)..(length(ws)))
    new_wc = hide(wc)
    slice1 ++ new_wc ++ slice2
  end

  @spec wstring_contains(wstring, wchar) :: boolean
  def wstring_contains(ws, wc) do
    List.keymember?(ws, wc, 0)
  end

  #return a wstring with all the visible wchars
  @spec wstring_value(wstring) :: wstring
  def wstring_value(ws) do
    {wstr,_} = Enum.partition(ws, fn({_,v,_,_,_}) -> v == true end)
    wstr
  end

  #return the ith visible wchar from the wstring
  @spec wstring_ith_visible(wstring, integer) :: wstring
  def wstring_ith_visible(ws, i) do
    ws_ = wstring_value(ws)
    Enum.at(ws_, i)
  end

  def wchar_get_id(wc) do
    {{id, clock},_,_,_,_} = wc
    {id, clock}
  end
end
