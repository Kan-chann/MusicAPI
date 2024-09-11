//
//  ViewController.swift
//  MusicAPI
//
//  Created by Kanno Taichi on 2024/09/02.
//

import UIKit

class ViewController: UIViewController,UISearchBarDelegate ,UITableViewDataSource{
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    var musicList: [Music] = []
    var artworks: [UIImage?] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    //語尾に?をつけることでOptional型にする　＞　画像取得　nilの時ように
    func getImage (url:URL)async -> UIImage?{
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil}
            return image
            
        }catch{
            return nil
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        let text = searchBar.text ?? ""
        
        Task{
            let response : MusicResponce? = await requestMusic(keyword: text)
            guard let musicResult = response else{return}
            musicList = musicResult.results
            
            artworks = []
            for music in musicList{
                let image = await getImage(url: music.artworkUrl60)
                artworks.append(image)
            }
            
            
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int{
        return musicList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.image = artworks[indexPath.row]
        content.text = musicList[indexPath.row].trackName
        cell.contentConfiguration = content
        
        return cell
    }
    
    func requestMusic(keyword : String) async -> MusicResponce?{
        let urlString = "https://itunes.apple.com/search?term=\(keyword)&entity=song&country=JP&lang=ja_jp&limit=20"
        
        //日本語の文字が含まれる時に必要な処理
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else{return nil}
        
        guard let url = URL(string: encodedUrlString)
        else {return nil }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {return nil}
            
            if httpResponse.statusCode == 200{
                let decodedData = try JSONDecoder().decode(MusicResponce.self, from: data)
                return decodedData
            }else{
                return nil
            }
        }catch{
            print(error)
            return nil
        }
    }
    
    


}

 
