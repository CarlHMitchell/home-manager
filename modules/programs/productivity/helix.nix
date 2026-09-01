{...}: {
  flake.modules.homeManager.helix = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.helix = {
      enable = true;
      languages = {};
      settings = {
        keys = {
          normal = {
            # -------------------------
            # from @mattmc3 (https://github.com/helix-editor/helix/issues/5520#issuecomment-1386428351)
            # QWERTY to Colemak remaps
            # [JY] [LU] [UI] [..]
            #  [..] [NJ] [EK] [IL]
            #   [KN] [..] [..] [..]
            # -------------------------
            # N <=> K (K is in the QWERTY N position)
            n = "move_char_left";
            N = "keep_selections";
            k = "search_next";
            K = "search_prev";
            # E <=> J (J now 'jumps words')
            e = "move_line_down";
            E = "join_selections";
            j = "move_next_word_end";
            J = "move_next_long_word_end";
            # H <=> I (H is just a sideways I)
            i = "move_char_right";
            I = "no_op";
            h = "insert_mode";
            H = "insert_at_line_start";
            # U <=> L (L is in the QWERTY U position)
            u = "move_line_up";
            U = "no_op";
            l = "undo";
            L = "redo";
          };
          select = {
            # -------------------------
            # from @mattmc3 (https://github.com/helix-editor/helix/issues/5520#issuecomment-1386428351)
            # QWERTY to Colemak remaps
            # [JY] [LU] [UI] [..]
            #  [..] [NJ] [EK] [IL]
            #   [KN] [..] [..] [..]
            # -------------------------
            # N <=> K (K is in the QWERTY N position)
            n = "extend_char_left";
            N = "keep_selections";
            k = "extend_search_next";
            K = "extend_search_prev";
            # E <=> J (J now 'jumps words')
            e = "extend_visual_line_down";
            E = "join_selections";
            j = "extend_next_word_end";
            J = "extend_next_long_word_end";
            # H <=> I (H is just a sideways I)
            i = "extend_char_right";
            I = "no_op";
            h = "insert_mode";
            H = "insert_at_line_start";
            # U <=> L (L is in the QWERTY U position)
            u = "extend_visual_line_up";
            U = "no_op";
            l = "undo";
            L = "redo";
          };
        };
      };
    };
  };
}
