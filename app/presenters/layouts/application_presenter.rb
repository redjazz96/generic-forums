class Layouts::ApplicationPresenter < Curly::Presenter

  def title
    content_for(:title) || Setting.forum.name
  end

  def stylesheets
    stylesheet_link_tag "application", Setting.forum.style,
      media: "all"
  end

  def javascripts
    javascript_include_tag "application"
  end

  def mathjax
    #mathjax_tag config: "TeX-AMS-MML_SVG"
    javascript_include_tag "//cdn.mathjax.org/mathjax/latest/MathJax" \
      ".js?config=TeX-AMS-MML_HTMLorMML,Safe&" \
      "delayStartupUntil=configured"
  end

  def csrf
    csrf_meta_tags
  end

  def header
    render "shared/header"
  end

  def body
    yield
  end

  def footer
    render "shared/footer"
  end

end
