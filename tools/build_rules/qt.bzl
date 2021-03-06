def qt_ui_library(name, ui, deps):
  """Compiles a QT UI file and makes a library for it.

  Args:
    name: A name for the rule.
    src: The ui file to compile.
    deps: cc_library dependencies for the library.
  """
  native.genrule(
      name = "%s_uic" % name,
      srcs = [ui],
      outs = ["ui_%s.h" % ui.split('.')[0]],
      cmd = "/usr/bin/uic $(locations %s) -o $@" % ui,
  )

  native.cc_library(
      name = name,
      hdrs = [":%s_uic" % name],
      deps = deps,
  )

def qt_cc_library(name, src, hdr, deps, ui=None, ui_deps=None, **kwargs):
  """Compiles a QT library and generates the MOC for it.

  If a UI file is provided, then it is also compiled with UIC.

  Args:
    name: A name for the rule.
    src: The cpp file to compile.
    hdr: The header file corresponding to the src.
    deps: cc_library dependencies for the library.
    ui: If provided, a UI file to compile with UIC.
    ui_deps: Dependencies for the UI file.
    kwargs: Any additional arguments are passed to the cc_library rule.
  """
  native.genrule(
      name = "%s_moc" % name,
      srcs = [hdr],
      outs = ["moc_%s.cpp" % name],
      cmd = "/usr/bin/moc $(locations %s) -o $@" % hdr,
  )
  srcs = [src, ":%s_moc" % name]

  if ui:
    qt_ui_library("%s_ui" % name, ui, deps=ui_deps)
    deps.append("%s_ui" % name)

  native.cc_library(
      name = name,
      srcs = srcs,
      hdrs = [hdr],
      deps = deps,
      **kwargs
  )
