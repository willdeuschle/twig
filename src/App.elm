port module App exposing (..)

import Simplify exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as App


-- MODEL


type alias Model =
    { url : String, simplifiedText : String, title : String }



-- leaving the init verbose for clarity


initModel : Model
initModel =
    { url = "", simplifiedText = "", title = "" }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )


type alias ArticlePayload =
    { title : String, article : String }



-- UPDATE


type Msg
    = UpdateUrl String
    | GetArticle
    | ArticleReceived { article : String, title : String }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateUrl url ->
            ( { model | url = url }, Cmd.none )

        GetArticle ->
            ( { model | title = "Loading...", simplifiedText = "" }, getArticle model.url )

        ArticleReceived articlePayload ->
            ( { model | title = articlePayload.title, simplifiedText = (simplify articlePayload.article) }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "top-level" ]
        [ div [ class "text-container" ]
            [ textarea
                [ placeholder "Enter the passage here..."
                , onInput UpdateUrl
                , value model.url
                , class "to-simplify"
                ]
                []
            ]
        , hr [] []
        , div []
            [ button [ onClick GetArticle ] [ text "Simplify" ]
            ]
        , hr [] []
        , h2 []
            [ text model.title ]
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


port articleReceived : (ArticlePayload -> msg) -> Sub msg


main : Program Never
main =
    App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
