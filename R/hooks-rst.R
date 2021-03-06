# SET OF HOOKS FOR RESTRUCTURED TEXT ---

#' @rdname hook_plot
#' @export
hook_plot_rst = function(x, options) {
  if (options$fig.show == 'animate') return(hook_plot_html(x, options))

  cap = .img.cap(options)
  # TODO: add all options for figure
  # See http://docutils.sourceforge.net/docs/ref/rst/directives.html#image
  # http://docutils.sourceforge.net/docs/ref/rst/directives.html#figure
  make_directive(
    'figure',
    paste(opts_knit$get('base.url'), .upload.url(x), sep = ''),
    c(align = if (options$fig.align == 'default') NULL else options$fig.align,
      alt = cap, width = options$out.width, height = options$out.height),
    cap
  )
}

#' @rdname output_hooks
#' @export
render_rst = function(strict = FALSE) {
  knit_hooks$restore()
  set_html_dev()
  hook.s = function(x, options) {
    paste(c('\n\n::\n', indent_block(x), ''), collapse = '\n')
  }
  hook.t = function(x, options) {
    make_directive('sourcecode', tolower(options$engine), '', content = x)
  }
  hook.i = function(x) .inline.hook(format_sci(x, 'rst'))
  knit_hooks$set(
    source = function(x, options) {
      x = paste(c(hilight_source(x, 'rst', options), ''), collapse = '\n')
      (if (strict) hook.s else hook.t)(x, options)
    },
    warning = hook.s, error = hook.s, message = hook.s,
    output = hook.s, inline = hook.i, plot = hook_plot_rst)
}

# Insert a reStructuredText directive for sphinx
#
# A reSt directive consists of  a name, arguments, option and some content.
# A typical reSt directive looks like this:
# .. <name>:: <arguments>
#    :<option>: <option values>
#
#     content
#
# This function accepts these arguments and returns the correctly formatted
# reStructuredText directive
#  Input
#      make_directive('figure', 'fig.png', c(align = 'center', alt = 'cap'))
#  Output
#  .. figure:: fig.png
#      :align: center
#      :alt: cap
make_directive = function(name, arg, opt, content = '') {
  l1 = sprintf('\n.. %s:: %s\n', name, arg)
  l2 = paste(sprintf(':%s: %s', names(opt), opt), collapse = '\n')
  paste(l1, indent_block(l2), '\n\n', indent_block(content), sep = '')
}
