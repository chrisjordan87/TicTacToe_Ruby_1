require 'qt'

module TTT
  module UI
    class QTCell < Qt::Label

      def initialize(parent, cell_number)
        super(nil)
        self.alignment = Qt::AlignHCenter
        self.frame_style = Qt::Frame::WinPanel
        self.setFont Qt::Font.new "Purisa", 40
        @parent = parent
        @cell_number = cell_number
      end

      def mousePressEvent(_)
        @parent.board_clicked(@cell_number)
      end
    end
  end
end
