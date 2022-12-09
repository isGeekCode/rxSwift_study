//
//  PromiseViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import PromiseKit
import UIKit

class PromiseViewController: UIViewController {
    // MARK: - Field
    
    var counter: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.counter += 1
            self.countLabel.text = "\(self.counter)"
        }
    }

    // MARK: - IBOutlet

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var countLabel: UILabel!

    // MARK: - IBAction

    @IBAction func onLoadImage(_ sender: Any) {
        imageView.image = nil

        promiseLoadImage(from: LARGER_IMAGE_URL)
            .done { image in
                self.imageView.image = image
            }.catch { error in
                print(error.localizedDescription)
            }
    }

    // MARK: - PromiseKit

    func promiseLoadImage(from imageUrl: String) -> Promise<UIImage?> {
        return Promise<UIImage?>() { seal in
            asyncLoadImage(from: imageUrl) { image in
                seal.fulfill(image)
            }
        }
    }
}

/**
 로직정리
 
 1.  onLoadImage 버튼클릭
 
 2. `promiseLoadImage(from: LARGER_IMAGE_URL)`
     
     imageURL을 Promise<UIImage>로 리턴하고 seal에 담아서 그대로 파라미터로 내려준다.
     
 3. `asyncLoadImage(from: imageUrl), completed: @escaping(UIImage?) -> Void)`
     
     imageUrl을 받아서 global큐에서 비동기처리로 `syncLoadImage(from:  )`의 파라미터로 넣어준다.
     
 4. 4번함수 <**동기 부분> urlString → URL → data → UIImage**
     
     `asyncLoadImage(from: imageUrl)` 에서 파라미터인 imageUrl을 URL로 바꾸고 URL을 data형태로 바꿔준다. 마지막으로 UIImage로 파싱해서 리턴한다.
     
     imageUrl: String → data → UIImage
     
 5.   4번에서 리턴받은 image는 3번함수에서 상수 image에 담겨 `completed`탈출클로저에 저장된다.
 6.   이 image는 2번함수에서 3번함수의 후행클로저로 실행되고 `image in` 이 들어가면서 image에 담긴다
 7.   image는  2번함수의 promise 에서 받은 `seal.fulfill()`의 매개변수로 들어간다
 8. 1번함수→ 2번함수→ 3번함수→ 4번함수→ 3번함수→2번함수→`1번함수` 의 과정에서 마지막단계로 1번함수내부에 있는 2번함수의 Promise 실행부분이 시작된다.
 9. 8번로직을 모두 돌면 .`done{ }` 클로저가 실행되는데 `image in` 으로 변수 image에 image가 담긴다.
     
     ```swift
             promiseLoadImage(from: LARGER_IMAGE_URL)
            //promise가 나와야 이후에 이 로직이 실행이 된다.

               .done { image in
                   self.imageView.image = image
               }.catch { error in
                   print(error.localizedDescription)
               }
     ```
     
     이 image는 `self.imageView.image`에 담기고 `catch{ }` 클로저를 통해 에러체크를 하면서 로직이 종료된다.
 */
