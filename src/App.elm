port module App exposing (..)

import String exposing (isEmpty)
import Simplify exposing (simplify)
import Highlight exposing (highlight)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as App


-- MODEL


type alias Model =
    { url : String, simplifiedText : String, articleText : String, title : String }



-- leaving the init verbose for clarity


initModel : Model
initModel =
    { url = "", simplifiedText = "", articleText = "", title = "" }


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
    | ArticleStatus Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateUrl url ->
            ( { model | url = url }, Cmd.none )

        GetArticle ->
            ( { model | title = "Loading...", simplifiedText = "" }, getArticle model.url )

        ArticleReceived articlePayload ->
            ( { model | title = articlePayload.title, simplifiedText = (simplify articlePayload.article articlePayload.title), articleText = articlePayload.article }, Cmd.none )

        ArticleStatus status ->
            if status then
                ( model, Cmd.none )
            else
                ( { model | title = "Sorry, that url is currently non-functional." }, Cmd.none )



-- VIEW


initialView : Model -> Html Msg
initialView model =
    let
        spiel1 =
            "Hello! I developed this project to learn more about the Elm programming language. To view its source, or run the project locally, head over to: "

        spiel2 =
            "To use the project, paste a url from a Medium article into the search bar. For example: https://medium.com/the-starbucks-collection/coffee-and-wine-ed058b0dc6ed#.1lhz7h3uo"
    in
        if isEmpty model.title then
            div [ class "description" ]
                [ text spiel1
                , a [ class "github-link", href "https://github.com/willdeuschle/twig" ] [ text "https://github.com/willdeuschle/twig" ]
                , div [ class "sub-description" ]
                    [ text spiel2
                    ]
                ]
        else
            div [] []


view : Model -> Html Msg
view model =
    div [ class "top-level" ]
        [ div [ class "header-bar" ]
            [ h1 [] [ text "Medium Simplifier" ]
            ]
        , div [ class "main-container" ]
            [ div [ class "url-container" ]
                [ input
                    [ placeholder "Enter the Medium article url here..."
                    , onInput UpdateUrl
                    , value model.url
                    , class "to-simplify"
                    ]
                    []
                , button [ class "simplify-button", onClick GetArticle ] [ text "Simplify" ]
                ]
            , br [] []
            , div [ class "article-container" ]
                [ h2 []
                    [ text model.title ]
                , initialView model
                , br [] []
                , div [ class "simplified-text" ]
                    [ text model.simplifiedText ]
                , highlight model.articleText model.title
                ]
            ]
        ]



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ articleReceived ArticleReceived
        , articleStatus ArticleStatus
        ]


port getArticle : String -> Cmd msg


port articleReceived : (ArticlePayload -> msg) -> Sub msg


port articleStatus : (Bool -> msg) -> Sub msg


main : Program Never
main =
    App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
