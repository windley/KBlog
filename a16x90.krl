ruleset a16x90 {
  meta {
    name "KBlog Posting"
    description <<
Ruleset to post to KBlog. This is intended to be used as a extension to only allow people with the bookmarket to post. 
    >>
    author "Phil Windley"
    logging off
  }

  dispatch {
  }

  global {
  }
  
  rule place_button {
    select when pageview "kblog"
    pre {
      button = <<
<li><a href="javascript:void(0);" id="siteNavPost">Post</a></li>
       >>;
    }
    {
     prepend("#navlist", button);
     watch("#siteNavPost",  "click");
    }
  }

  rule place_form {
    select when web click "#siteNavPost"
    pre {
      form = <<
<div id="leftcontainer">
<h2 class="mainheading">Post</h2> 
<article class="post">
 <form onsubmit="return false" method="post" class="form" id="blogform">
   <p class="textfield">
    <label for="postauthor"><small>Name</small></label>
    <input name="postauthor" id="postauthor" value="" size="22" tabindex="1" type="text">
   </p>
   <p class="textfield">
    <label for="posttitle"><small>Title</small></label>
    <input name="posttitle" id="posttitle" value="" size="22" tabindex="2" type="text">
   </p>
   <p>
    <small>Body</small>
   </p>
   <p class="text-area">
    <textarea name="postbody" id="postbody" cols="50" rows="10" tabindex="4"></textarea>
   </p>
   <p>
    <input name="submit" id="submit" tabindex="5" type="image" src="images/submit.png">
   </p>
   <div class="clear"></div>
  </form>
 </article>
 </div>
     >>;
   }
   {
    replace_html("#leftcontainer",form);
    watch("#blogform", "submit");
   }
  }
  
  rule handle_submit {
    select when submit "#blogform"
    always {
      raise explicit event new_article_available for a16x89 with
        postauthor = event:param("postauthor") and
        posttitle = event:param("posttitle") and
        postbody = event:param("postbody");
    }
  }
}
