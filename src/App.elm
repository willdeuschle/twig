port module App exposing (..)

import Simplify exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as App


-- MODEL


type alias Model =
    { text : String, simplifiedText : String }



-- leaving the init verbose for clarity


initModel : Model
initModel =
    { text = "", simplifiedText = "" }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- UPDATE


type Msg
    = UpdateUrl String
    | GetArticle
    | ArticleReceived String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateUrl text ->
            ( { model | text = text }, Cmd.none )

        GetArticle ->
            ( model, getArticle model.text )

        ArticleReceived article ->
            ( { model | simplifiedText = (simplify article) }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "top-level" ]
        [ div [ class "text-container" ]
            [ textarea
                [ placeholder "Enter the passage here..."
                , onInput UpdateUrl
                , value model.text
                , class "to-simplify"
                ]
                []
            ]
        , hr [] []
        , div []
            [ button [ onClick GetArticle ] [ text "Simplify" ]
            ]
        , hr [] []
        , div []
            [ text model.simplifiedText ]
        ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ articleReceived ArticleReceived
        ]


port getArticle : String -> Cmd msg


port articleReceived : (String -> msg) -> Sub msg


main : Program Never
main =
    App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
