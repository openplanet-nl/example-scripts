#name "SimpleMapDetails"
#author "derfuhr"

bool windowIsVisible = false;

void Main(){

}

void RenderMenu(){
	if(UI::MenuItem("SimpleMapDetails", "", false)) {
		windowIsVisible = true;
	}
}

void RenderInterface(){
	if(!windowIsVisible){
		return;
	}
	UI::SetNextWindowPos(40, 40, UI::Cond::Appearing, 0.0f, 0.0f);
	UI::Begin("SimpleMapDetails", UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse);
	CGameCtnApp@ app = cast<CGameCtnApp>(GetApp());
	if(app !is null){
		CGameCtnChallenge@ challenge = cast<CGameCtnChallenge>(app.Challenge);
		if(challenge !is null){
			CGameCtnChallengeInfo@ challengeInfo = cast<CGameCtnChallengeInfo>(challenge.MapInfo);
			if(challengeInfo !is null){
				UI::Text("MapUid: " + challengeInfo.MapUid);
				UI::Text("Mapname: " + challenge.MapName);
				UI::Text("Mapname(Stripped): " + StripFormatCodes(challenge.MapName));
				UI::Text("AuthorLogin: " + challenge.AuthorLogin);
				UI::Text("AuthorNickName: " + challenge.AuthorNickName);
				UI::Text("AuthorNickName(Stripped): " + StripFormatCodes(challenge.AuthorNickName));
				UI::Text("LapRace: " + challengeInfo.LapRace);
				if(challengeInfo.LapRace){
					CTrackManiaRace@ race = cast<CTrackManiaRace>(app.CurrentPlayground);
					if(race !is null){
						UI::Text("LapsCount: " + race.LapCount);
					}
				}
				UI::Text("CollectionName: " + challenge.CollectionName);
			}
			CGameCtnChallengeParameters@ params = cast<CGameCtnChallengeParameters>(challenge.ChallengeParameters);
			if(params !is null){
				UI::Text("AuthorTime: " + params.AuthorTime);
				UI::Text("GoldTime: " + params.GoldTime);
				UI::Text("SilverTime: " + params.SilverTime);
				UI::Text("BronzeTime: " + params.BronzeTime);
				UI::Text("MapType: " + params.Type);
			} 
		} 
	}
	if (UI::Button("Close SimpleMapDetails-Window")) {
		windowIsVisible = false;
	}
	UI::End();
}

string StripFormatCodes(string s){
	return Regex::Replace(s, "\\$([0-9a-fA-F]{1,3}|[iIoOnNmMwWsSzZtTgG<>]|[lLhHpP](\\[[^\\]]+\\])?)", "");
}
