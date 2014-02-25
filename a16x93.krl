ruleset a16x93 {
  meta {
    name "KBlog Configuration"
    description <<

    >>
    author ""
    logging off
    provides blogtitle, about_text, paint_container, place_button, update_frag
  }

  dispatch {
  }

  global {
    blogtitle = "Kynetx Blog";
    about_text = <<
<p>The Kynetx Blog is built entirely with <a href="http://developer.kynetx.com">KRL</a>, the Kynetx Rule Language.
Four separate rulesets control the operation of the Kynetx Blog. See <a href="http://www.windley.com/archives/2011/04/tweeting_from_kblog_thoughts_about_loose_coupling.shtml">this blog post for more information</a>.</p>
     >>;
     
    update_frag = defaction(name) {
      emit <|
          KOBJ.a16x88.previous = '#!#{name}';
          self.document.location.hash='!#{name}';
         |>;
     };
     
    paint_container = defaction(title, container) {

     {
       replace_inner("title", title);
       replace_inner("#leftcontainer", container);
     }
    };
    
    place_button = defaction(button_name) {
      id = "siteNav" + button_name;
      label = button_name;
      button = <<
<li><a href="javascript:void(0);" id="#{id}">#{label}</a></li>
      >>;
      {
        prepend("#navlist", button);
        watch("#" + id, "click");
      }
    };
  }

}
