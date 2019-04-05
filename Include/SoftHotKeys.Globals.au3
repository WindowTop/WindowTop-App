Global $SoftHotKeys_hGUI

Global Enum $SoftHotKeys_idx_id, $SoftHotKeys_idx_key,$SoftHotKeys_idx_aCombSum, $SoftHotKeys_idx_aComb, $SoftHotKeys_idxmax

Global Const $SoftHotKeys_IdFor_TClickThroughAnyOpcWin = 0x1, $SoftHotKeys_IdFor_SetWindowTop = 0x2, _
$SoftHotKeys_IdFor_SetWindowOpc = 0x3, $SoftHotKeys_IdFor_TShrink = 0x4

Global $TClickThroughAnyOpcWin_aSKey[$SoftHotKeys_idxmax] = [$SoftHotKeys_IdFor_TClickThroughAnyOpcWin], _
		$SetWindowTop_aSKey[$SoftHotKeys_idxmax] = [$SoftHotKeys_IdFor_SetWindowTop], _
		$SetWindowOpc_aSKey[$SoftHotKeys_idxmax] = [$SoftHotKeys_IdFor_SetWindowOpc], _
		$TShrink_aSKey[$SoftHotKeys_idxmax] = [$SoftHotKeys_IdFor_TShrink]


Global $tmp[1] = [0]
$TClickThroughAnyOpcWin_aSKey[$SoftHotKeys_idx_aComb] = $tmp
$SetWindowTop_aSKey[$SoftHotKeys_idx_aComb] = $tmp
$SetWindowOpc_aSKey[$SoftHotKeys_idx_aComb] = $tmp

$tmp = Null


Global $SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idxmax], $SoftHotKeys_SetKeyGUI_hGUI, $SoftHotKeys_SetKeyGUI_Input, _
		$SoftHotKeys_SetKeyGUI_vkCode, $SoftHotKeys_SetKeyGUI_iFlags







