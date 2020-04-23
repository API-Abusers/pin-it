/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The annotation view representing multiple bike annotations in a clustered annotation.
*/
import MapKit

/// - Tag: ClusterAnnotationView
class ClusterAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10) // Offset center point to animate better with marker annotations
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// - Tag: CustomCluster
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        if let cluster = annotation as? MKClusterAnnotation {
            let totalPins = cluster.memberAnnotations.count
            let color = #colorLiteral(red: 0.9973643422, green: 0.4707460999, blue: 0.4720540643, alpha: 1)
            image = drawRatio(totalPins, to: totalPins, fractionColor: nil, wholeColor: color)
            displayPriority = .defaultLow
        }
    }
    
    private func drawRatio(_ fraction: Int, to whole: Int, fractionColor: UIColor?, wholeColor: UIColor?) -> UIImage {
        // find adjustment needed based on digit count
        let desc = whole.shortenedDescription
        let length = desc.count
        var adjustment = length >= 2 ? length - 2 : 0
        adjustment *= 8
        let dim = 40 + adjustment
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: dim, height: dim))
        return renderer.image { _ in
            
            // Fill full circle with wholeColor
            wholeColor?.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0,
                                        y: 0,
                                        width: dim,
                                        height: dim)).fill()

            // Fill pie with fractionColor
            if let fractionColor = fractionColor {
                fractionColor.setFill()
                let piePath = UIBezierPath()
                piePath.addArc(withCenter: CGPoint(x: dim / 2,
                                                   y: dim / 2),
                               radius: CGFloat(dim / 2),
                               startAngle: 0,
                               endAngle: (CGFloat.pi * 2.0 * CGFloat(fraction)) / CGFloat(whole),
                               clockwise: true)

                piePath.addLine(to: CGPoint(x: dim / 2, y: dim / 2))
                piePath.close()
                piePath.fill()
            }

            // Fill inner circle with white color
            UIColor.white.setFill()
            UIBezierPath(ovalIn: CGRect(x: 8,
                                        y: 8,
                                        width: 24 + adjustment,
                                        height: 24 + adjustment)).fill()

            // Finally draw count text vertically and horizontally centered
            let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                               NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20 - length <= 7 ? 7 : CGFloat(20 - length))]
            let text = "\(desc)"
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: CGFloat(dim / 2) - size.width / 2,
                              y: CGFloat(dim / 2) - size.height / 2,
                              width: size.width,
                              height: size.height)
            text.draw(in: rect, withAttributes: attributes)
        }
    }
}
