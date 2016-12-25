module Highlight exposing (highlight)

import Html exposing (..)
import Html.Attributes exposing (..)
import Simplify exposing (genGoodSentenceIds, genSentenceList)
import List exposing (..)
import Array


indivSent : String -> Int -> List Int -> Html msg
indivSent sent idx ids =
    if List.member idx ids then
        mark [] [ text (sent ++ " ") ]
    else
        span [] [ text (sent ++ " ") ]


highlight : String -> String -> Html msg
highlight str title =
    let
        ids =
            genGoodSentenceIds str title
    in
        div [ class "article-text" ]
            (List.map (\( idx, sent ) -> indivSent sent idx ids) (Array.toIndexedList (Array.fromList (genSentenceList str))))
