# This files contains your custom actions which can be used to run
# custom Python code.
#
# See this guide on how to implement these action:
# https://rasa.com/docs/rasa/custom-actions


# This is a simple example for a custom action which utters "Hello World!"

from typing import Any, Text, Dict, List

from rasa_sdk import Action, Tracker
from rasa_sdk.events import SlotSet
from rasa_sdk.executor import CollectingDispatcher

class Tournament:
    def __init__(self, name, players = []):
        self.name = name
        self.players = players

tournaments = [
    Tournament("Summer Split (LoL)"),
    Tournament("Minecraft Speedrun Tournament", [
        "Tomek1337",
        "Maciek2008PL"
    ]),
    Tournament("Mortal Kombat Championships", [
        "Kasia12",
        "PolishPlayer2137"
    ])
]

class ActionListTournaments(Action):

    def name(self) -> Text:
        return "action_list_tournaments"

    def run(self, dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any]
    ) -> List[Dict[Text, Any]]:

        if len(tournaments) >= 1:
            joined_tournaments = tournaments[0].name
            for i in range(1, len(tournaments)):
                joined_tournaments += ',\n' + tournaments[i].name
            dispatcher.utter_message(text=f"Current tournaments:\n{joined_tournaments}")
        else:
            dispatcher.utter_message(text=f"There are no tournaments right now")

        return []

class ActionConfirmTournamentName(Action):
    def name(self) -> Text:
        return "action_confirm_tournament_name"

    def run(self, dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any]
    ) -> List[Dict[Text, Any]]:

        tournament_name = next(tracker.get_latest_entity_values("tournament"), None)

        tournament_index = -1
        for i in range(len(tournaments)):
            tournament = tournaments[i]
            if tournament.name.upper().find(tournament_name.upper()) >= 0:
                tournament_index = i
                break
        
        if tournament_index >= 0:
            dispatcher.utter_message(f"Did you mean {tournaments[tournament_index].name}?")
        else:
            dispatcher.utter_message(f"Couldn't find a tournament with that name")
        return [SlotSet("tournament_index", tournament_index)]

class ActionListCompetitors(Action):
    def name(self) ->Text:
        return "action_list_competitors"

    def run(self, dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: Dict[Text, Any]
    ) -> List[Dict[Text, Any]]:

        tournament_index = tracker.get_slot("tournament_index")

        if tournament_index >= 0 and tournament_index < len(tournaments):
            tournament_name = tournaments[tournament_index].name
            players = tournaments[tournament_index].players
            if len(players) >= 1:
                joined_players = players[0]
                for i in range(1, len(players)):
                    joined_players += ',\n' + players[i]
                dispatcher.utter_message(f"{tournament_name} participants:\n{joined_players}")
            else:
                dispatcher.utter_message(f"There are currently no players in {tournament_name}")
        else:
            dispatcher.utter_message(f"Tournament with this name was not found")

        return []
