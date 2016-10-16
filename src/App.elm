module App exposing (..)

import Simplify exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as App


-- MODEL


type alias Model =
    { text : String, simplifiedText : String }


initModel : Model
initModel =
    { text = "", simplifiedText = "" }



-- UPDATE


type Msg
    = UpdateText String
    | Evaluate


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateText text ->
            { model | text = text }

        Evaluate ->
            { model | simplifiedText = (simplify model.text) }



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "top-level" ]
        [ div [ class "text-container" ]
            [ textarea
                [ placeholder "Enter the passage here..."
                , onInput UpdateText
                , value model.text
                , class "to-simplify"
                ]
                []
            ]
        , hr [] []
        , div []
            [ button [ onClick Evaluate ] [ text "Evaluate" ]
            ]
        , hr [] []
        , div []
            [ text (toString (genGoodSentenceList model.text))
            ]
        , div []
            [ text (toString (genSentenceList model.text))
            ]
        , div []
            [ text model.simplifiedText ]
        ]


main : Program Never
main =
    App.beginnerProgram
        { model = initModel
        , update = update
        , view = view
        }
