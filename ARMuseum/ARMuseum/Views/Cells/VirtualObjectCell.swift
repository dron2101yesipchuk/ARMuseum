import UIKit

class VirtualObjectCell: UITableViewCell {

  @IBOutlet weak var virtualObjectImageView: UIImageView!
  @IBOutlet weak var virtualObjectNameLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureWith(modelImage: UIImage, modelName: String) {
        self.virtualObjectImageView.image = modelImage
        self.virtualObjectNameLabel.text = modelName
    }

}
