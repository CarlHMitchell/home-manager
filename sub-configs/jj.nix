{
  config,
  lib,
  pkgs,
  ...
}: {

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "carl.mitchell@gomotive.com";
        name = "Carl Mitchell";
        signing.behavior = "own";
        signing.backend = "ssh";
        signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6uxGJ1DLnFasXcRQYp7tM7UL0vVfV+5Fg7IKSxGfuu carl@carl-thinkpad-pw0j0jnb";
        git = {
          sign-on-push = true;
        };
        ui = {
          dif-formatter = ["difft" "--color=always" "$left" "$right"];
          show-cryptographic-signatures = true; # May be slow
        };
        aliases = {
          ps = ''
            [ "util", "exec", "--", "bash", "-c", """,
            set -e
            # Check if current commit has both description and changes
            has_description=$(jj log -r @ --no-graph --color never -T 'description' | grep -q . && echo "yes" || echo "no")
            # Use 'empty' template keyword to check if commit has changes
            has_changes=$(jj log -r @ --no-graph --color never -T 'empty' | grep -q "false" && echo "yes" || echo "no")
            
            if [ "$has_description" = "yes" ] && [ "$has_changes" = "yes" ]; then
                echo "Current commit has description and changes, creating new commit..."
                jj new
            fi
            
            # Get the bookmark from the parent commit directly
            bookmark=$(jj log -r 'ancestors(@) & bookmarks()' -n 1 --no-graph --color never -T 'bookmarks' | sed 's/\\*$//' | tr -d ' ')
            
            if [ -z "$bookmark" ]; then
                echo "No bookmark found on parent commit"
                exit 1
            fi
            
            echo "Moving bookmark '$bookmark' to parent commit and pushing..."
            jj bookmark set "$bookmark" -r @-
            jj git fetch
            jj git push --bookmark "$bookmark" --allow-new
            """]
          '';
        };
      };
    };
  };
}
