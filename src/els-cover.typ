#import "els-journal.typ": *

#let top-bar(
  logo: image("resources/itc_logo_text.png", height: 100%),
  header,
  journal-image: none
) = table(
  columns: (2.5cm, 1fr, 2.5cm),
  rows: (1pt, 2.5cm, auto),
  column-gutter: 1em,
  row-gutter: 0.5em,
  align: (left+horizon, center, left),
  stroke: none,
  table.hline(stroke: 1.5pt),
  table.cell(colspan: 2)[],
  table.cell(rowspan: 2,
    inset: (
      top: 5pt,
      right: 0pt,
      bottom: 0pt,
      left: 0pt
    ), journal-image),
  table.cell(
    inset: (
      top: -3pt,
      rest: 0pt
    ),
    logo
  ),
  table.cell(
    fill: gray.lighten(80%),
    header
  ),
  // table.cell(inset: 2pt, colspan: 3)[],
  table.hline(stroke: 3pt + rgb("#009193"))
)

#let make-precis(
  keywords: (),
  abstract: [],
  extra-info: none
) = table(
  inset: (x: 0pt, y: 0pt),
  stroke: none,
  table.hline(stroke: 0.5pt + rgb("#009193")),
  block(inset: 5pt, fill: rgb("#f4f4f4"))[
    #par(justify: true, text(size: 10pt, weight: "bold", "Abstract: ") + text(size: 10pt, style: "italic", abstract))
  ],
  table.hline(stroke: 0.5pt + rgb("#009193")),
  text()[
    #v(4pt)
    #text(size: 10pt, weight: "bold", "Keywords: ")
    #text(size: 10pt, keywords.join([,]))
    #v(4pt)
  ],
  table.hline(stroke: 0.5pt + rgb("#009193")),
)

#let make-institution(key, value) = {
  super[#key]
  [#metadata("") #label("institution."+key)]
  if key != "" {
    sym.space.thin
  }
  text(style:"italic", value)
}

#let make-institutions(institutions) = align(center,{
  set text(size: 10pt)
  for (key, value) in institutions{
    make-institution(key, value)
    linebreak()
  }
})

#let make-author(author) = box({
  author.name

  let auth-institution = if author.institutions.at(0) == "" {
    none
  } else {
    author.institutions.map((key)=>{
      text(fill: rgb(0,0,102), link(label("institution."+key), key))
    })
  }

  let auth-rest = {
    if (author.at("orcid", default: none)) != none {(link(author.orcid, box(image("resources/orcid.svg", height: 1.1em))),)} + if (author.at("corresponding", default: false) == true){
      (text(fill: rgb(33, 150,209), sym.ast),)
    }
  }

  sym.space.thin
  if auth-institution == none {
    super({
      auth-rest.join([ ])
    })
  } else {
    super({
      (auth-institution + auth-rest).join([,])
    })
  }
})

#let make-authors(authors) = align(center, {
  set text(size: 12pt)
  authors.map(make-author).join(", ")
})

#let make-title(
  paper-type: [Document heading],
  title: [Full length journal article adapted and reset according to the typesetting specifications for this model],
  authors: (),
  institutions: ()
) = {
  show par: block.with(below: 0em)
  // v(0.75em)
  // par(text(size: 9.6pt, paper-type))
  // v(1.5em)
  align(center, text(size: 15pt, weight: "bold", title))
  v(1.5em)
  make-authors(authors)
  v(1.25em)
  make-institutions(institutions)
  v(0.75em)
}

#let make-header(
  authors,
  journal,
  paper-info
) = {
  let authors-header = if authors.len() > 2 {
    authors.first().name + " et al."
  } else if authors.len() == 2 {
    authors.at(0).name + " and " + authors.at(1).name
  } else {
    authors.first().name
  }

  let doi = if paper-info.doi != none {
    paper-info.doi
  } else {
    ""
  }

  let journal-header = [#journal.name #paper-info.volume (#paper-info.year)  #paper-info.paper-id]

  return context if counter(page).get().first() == 1 {
    align(center,text(size: 11pt)[#link(doi, journal-header)])
  } else {
      grid(
        columns: (1fr, 1fr),
        align: (left, right),
        [#text(size: 6.4pt, style: "italic")[#authors-header]],
        [#text(size: 6.4pt, style: "italic")[#journal-header]],
    )
  }
}

#let make-footer(
  paper-info, journal
) = context if counter(page).get().first() == 1 {
    v(-3em)
    align(left, text(size: 7.2pt,[
      #let open-access-info = if paper-info.open != none {
        [This is an open access article under the #paper-info.open.name license (#link(paper-info.open.url))]
      } else {
        none
      }

      #par(justify: true)[
        #if paper-info.doi != none {
          link(paper-info.doi)
        } \
        Received #paper-info.received\; Received in revised form #paper-info.revised\; Accepted #paper-info.accept \
        Available online #paper-info.online \
        #paper-info.issn/© #paper-info.year #journal.foot-info #open-access-info
      ]
    ]))
} else {
  align(center)[#text(size: 6.4pt)[#counter(page).get().first()]]
}

#let make-corresponding-author(
  authors,
) = for author in authors {
  if author.at("corresponding", default: false) == true {
    place(
      float: true,
      bottom,
      dy: -2em,
      {
        v(0.5em)
        line(length: 4em, stroke: 0.25pt)
        v(-0.75em)
        text(size: 6.4pt)[
          #h(0.2cm)#super[#text(size: 5pt)[#sym.ast]]#h(0.1cm);Corresponding author.\
          #h(0.4cm)_E-mail address:_ #if (author.at("email", default: none)) != none {link("mailto:"+author.email, author.email)} else {text("No email provided")} (#author.name).
        ]
      }
    )
  }
}
