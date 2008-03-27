dynasnip "link_to_current_snip", %{
  class LinkToCurrentSnip < Dynasnip
    def handle(*args)
      if context[:snip] == 'edit' # we're editing so don't use this name
        Routes.link_to context[:snip_to_edit]
      else
        Routes.link_to context[:snip]
      end
    end    
  end
  LinkToCurrentSnip
}