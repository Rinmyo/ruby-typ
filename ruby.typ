#let _ruby(rt, rb, size, pos, dy, alignment, delimiter) = {
    if not ("center", "start", "between", "around").contains(alignment) {
      panic("'" + repr(alignment) + "' is not a valid ruby alignment")
    }

    if not (top, bottom).contains(pos) {
      panic("pos can be either top or bottom but '"+ repr(pos) +"'")
    }

    let extract_content(content, fn: it => it) = {
      let func = content.func()
      return if func == text or func == raw { 
        (content.text, fn)
      } else {
        extract_content(content.body, fn: it => func(fn(it)))
      }  
    }

    let rb_array = if type(rb) == "content" {
        let (inner, func) = extract_content(rb)
        inner.split(delimiter).map(func)
    } else if type(rb) == "string" {
        rb.split(delimiter)
    } else {(rb,)}
    assert(type(rb_array) == "array")

    let rt_array = rt.split(delimiter)

    if rt_array.len() != rb_array.len() {
        rt_array = (rt,)
        rb_array = (rb,)
    }

    let gutter = if (alignment=="center" or alignment=="start") {
        h(0pt)
      } else if (alignment=="between" or alignment=="around") {
        h(1fr)
      }
    
    box(style(st=> {
        let sum_body = []
        let sum_width = 0pt
        let i = 0
        while i < rb_array.len() {
            let (body, ruby) = (rb_array.at(i), rt_array.at(i))
            let bodysize = measure(body, st)
            let rt_plain_width = measure(text(size: size, ruby), st).width
            let width = if rt_plain_width > bodysize.width {rt_plain_width} else {bodysize.width}
            let chars = if(alignment=="around") {
                h(0.5fr) + ruby.clusters().join(gutter) + h(0.5fr)
            } else {
                ruby.clusters().join(gutter)
            }
            let rubytext = box(width: width, align(if(alignment=="start"){left}else{center}, text(size: size, chars)))
            let textsize = measure(rubytext, st)
            let dx = textsize.width - bodysize.width
            let (t_dx, l_dx, r_dx) = if(alignment=="start"){(0pt, 0pt, dx)}else{(-dx/2, dx/2, dx/2)}
            let (l, r) = (i != 0,  i != rb_array.len() - 1)
            sum_width += if l {0pt} else {t_dx}
            let dy = if pos == top {-1.5 * textsize.height - dy} else {bodysize.height + textsize.height/2 + dy}
            place(
                top+left, 
                dx: sum_width, 
                dy: dy, 
                rubytext
            )
            sum_width += width
            sum_body += if l {h(l_dx)} + body + if r {h(r_dx)}
            i += 1
        }
        sum_body
    }))
}

#let get_ruby(
  size: .5em, 
  dy: 0pt, 
  pos: top,
  alignment: "center", 
  delimiter: "|"
) = (rt, rb, alignment: alignment) => _ruby(rt, rb, size, pos, dy, alignment, delimiter)

#let test() = [
  #set box(stroke: red+.001pt)
  #set text(size: 50pt)
  #show: align.with(center)
  #let ruby = get_ruby(pos: bottom)
  #ruby("した")[下]
  #let ruby = get_ruby()
  #ruby("うえ")[上]
]

//#test()
