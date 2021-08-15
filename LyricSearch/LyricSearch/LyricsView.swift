//
//  LyricsView.swift
//  LyricsView
//
//  Created by Deborah Newberry on 8/11/21.
//

import SwiftUI
import CoreData

struct LyricsView: View {
    private let lyrics: MMLyrics
    
    init(lyrics: MMLyrics) {
        self.lyrics = lyrics
    }

    var body: some View {
        VStack {
            Text(lyrics.lyrics_body ?? "")
        }
    }
    
}


struct LyricsView_Previews: PreviewProvider {
    static var previews: some View {
        LyricsView(lyrics: MMLyrics())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension MMLyrics {
    private static let iNeedULyrics =
    """
    Fall (everything), fall (everything)
    Fall (everything)
    흩어지네
    Fall (everything), fall (everything)
    Fall (everything)
    떨어지네
    너 땜에 나 이렇게 망가져
    그만할래 이제 너 안 가져 (안 가져)
    못하겠어 뭣 같아서
    제발 핑계 같은 건 삼가줘 (삼가줘)
    네가 나한테 이럼 안 돼 (안 돼)
    네가 한 모든 말은 안대
    진실을 가리고 날 찢어
    날 찍어 나 미쳐 다 싫어
    전부 가져가 난 네가 그냥 미워
    But you're my everything (you're my)
    Everything (you're my)
    Everything (you're my)
    제발 좀 꺼져 huh
    미안해 (I hate you)
    사랑해 (I hate you)
    용서해 shit
    I need you girl
    왜 혼자 사랑하고 혼자서만 이별해
    I need you girl
    왜 다칠 걸 알면서 자꾸 네가 필요해
    I need you girl 넌 아름다워
    I need you girl 너무 차가워
    I need you girl (I need you girl)
    I need you girl, I need you girl
    It goes round and round 나 왜 자꾸 돌아오지
    I go down and down 이쯤 되면 내가 바보지
    나 무슨 짓을 해봐도 어쩔 수가 없다고
    분명 내 심장, 내 마음, 내 가슴인데
    왜 말을 안 듣냐고
    또 혼잣말하네 (또 혼잣말하네)
    또 혼잣말하네 (또 혼잣말하네)
    넌 아무 말 안 해, 아 제발 내가 잘할게
    하늘은 또 파랗게 (하늘은 또 파랗게)
    하늘이 파래서 햇살이 빛나서
    내 눈물이 더 잘 보이나 봐
    왜 나는 너인지 왜 하필 너인지
    왜 너를 떠날 수가 없는지
    I need you girl
    왜 혼자 사랑하고 혼자서만 이별해
    I need you girl
    왜 다칠 걸 알면서 자꾸 네가 필요해
    I need you girl 넌 아름다워
    I need you girl 너무 차가워
    I need you girl (I need you girl)
    I need you girl, I need you girl
    Girl 차라리 차라리 헤어지자고 해줘
    Girl 사랑이 사랑이 아니었다고 해줘 oh
    내겐 그럴 용기가 없어
    내게 마지막 선물을 줘
    더는 돌아갈 수 없도록 oh
    I need you girl
    왜 혼자 사랑하고 혼자서만 이별해
    I need you girl
    왜 다칠 걸 알면서 자꾸 네가 필요해
    I need you girl 넌 아름다워
    I need you girl 너무 차가워
    I need you girl (I need you girl)
    I need you girl, I need you girl
    """
    
    init() {
        self.init(instrumental: nil,
                  pixel_tracking_url: nil,
                  publisher_list: nil,
                  lyrics_language_description: nil,
                  restricted: nil,
                  updated_time: nil,
                  explicit: nil,
                  lyrics_copyright: nil,
                  html_tracking_url: nil,
                  lyrics_language: nil,
                  script_tracking_url: nil,
                  verified: nil,
                  lyrics_body: MMLyrics.iNeedULyrics,
                  lyrics_id: nil, writer_list: nil,
                  can_edit: nil,
                  action_requested: nil,
                  locked: nil)
    }
}
