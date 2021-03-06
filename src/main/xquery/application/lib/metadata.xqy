xquery version "1.0-ml";

module namespace meta = "http://marklogic.com/sem-app/metadata";

import module namespace search = "http://marklogic.com/appservices/search"
    at "/MarkLogic/appservices/search/search.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare option xdmp:mapping "false";

declare function meta:categories($uri, $results) {
  let $categories :=
    distinct-values(
      xdmp:document-properties($uri)//sem:triple
                                      [sem:predicate eq 'http://s.opencalais.com/1/pred/categoryName']
                                     /sem:object
    )
  ! (
     let $cat := .
     return $results/search:facet[@name eq 'cat']/search:facet-value[@name eq $cat]
    )
  return
    for $c in $categories order by $c/@name return $c
};

(: Here's how you might do the same thing using SPARQL,
   e.g. when the desired property values aren't already stored
   in the document's properties fragment.
declare function meta:categories($uri, $results) {

let $doc-id := doc($uri)/*:html/*:head/@resource/string()
let $categories :=
  sem:sparql("

    PREFIX c:   <http://s.opencalais.com/1/pred/>
    PREFIX r:   <http://s.opencalais.com/1/type/er/>
    PREFIX owl: <http://www.w3.org/2002/07/owl#>

    SELECT DISTINCT ?cat
    WHERE {
      ?DocInfo owl:sameAs <"||$doc-id||"> .

      ?DocCat c:docId ?DocInfo ;
              c:categoryName ?cat .

    }
  ")
  ! map:get(., "cat")
  ! (
     let $cat := .
     return $results/search:facet[@name eq 'cat']/search:facet-value[@name eq $cat]
    )
  return
    for $c in $categories order by $c/@name return $c
};
:)
